const Express = require('express');
const router = Express.Router();

const sample = function (arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

router.get('/', function (req, res) {
  res.render('index', {pick: '', names: ''});
})

router.get('/random', function (req, res) {
  res.render('random', {pick: '', names: ''});
})

router.post('/random', function (req, res) {
  const {names} = req.body; //(NEW!) Destructuring Objects

  res.render(
    'random',
    {pick: sample(names.split(/,\s*/)), names}  //(NEW!) Property Value Names
  );
})

module.exports = router;
