require("dotenv").config();

var express = require('express');
var path = require('path');
const cors =require('cors')
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const bodyParser = require('body-parser')

var drinkRouter = require("./routes/drink")
var userRouter = require("./routes/user")
var reviewRouter = require("./routes/review")

var app = express();

app.use(cors())
app.use(logger('dev'));
app.use(express.json());
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended:true}))
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

app.use(express.static(path.join(__dirname, 'public')));
app.use('/drink', drinkRouter);
app.use('/user',userRouter);
app.use('/review',reviewRouter);

module.exports = app;
