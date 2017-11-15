import React from 'react';
import { View } from 'react-native';
import { Button, BodyText } from './common';

function DiamondPurchaseOptions (props) {
  const { style = {}, options = [], onBuyPress = () => {} } = props;
  const { length } = options;

  return (
    <View style={style}>
      {
        options.map(
          ({id, quantity, price}, index) =>
            <DiamondPurchaseItem
              key={id}
              quantity={quantity}
              price={price}
              onPress={onBuyPress}
              style={{marginBottom: length - 1 === index ? 0 : 25}} />
        )
      }
    </View>
  );
}

function DiamondPurchaseItem (props) {
  const { id, quantity, price, onPress = () => {} } = props;
  const handlePress = () => onPress({id, quantity, price});
  const style = [
    {flexDirection: 'row', justifyContent: 'space-between'},
    props.style
  ];

  return (
    <View style={style}>
      <View style={{flexDirection: 'column'}}>
        <BodyText style={{fontSize: 18, fontWeight: 'bold'}}>
          {props.quantity} Diamonds
        </BodyText>
        <BodyText>${props.price}</BodyText>
      </View>
      <Button
        style={{width: 125}}
        type='purchase'
        title='Buy'
        onPress={handlePress} />
    </View>
  );
}

export default DiamondPurchaseOptions;
