var express = require("express");
var router = express.Router();
var multer = require("multer")
var db = require("../public/database/connect")

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'public/images/drinks');
    },
    filename: function (req, file, cb) {
        const destFileName = `${Date.now()}_${file.originalname}`
        cb(null,destFileName)
    }
  });


const upload = multer({ storage: storage });


router.post("/uploadDrinks",upload.single('image'), (req,res) => {
    try {
        const file = req.file.path;
        const {drinkName, drinkPrice, drinkDescription} = req.body

        if(file === "" || drinkPrice === "" || drinkDescription === "" || drinkName === ""){
            return res.status(403).json({error:"Field Can't Be Emptry"});
        }else if(drinkPrice <= 0){
            return res.status(403).json({error:"Drink Price Must More than 0"});
        }else{
            const query = "INSERT INTO MsDrinks (DrinkName,DrinkPrice, DrinkDescription, DrinkImage) VALUES (?,?,?,?)"
            db.query(query,[drinkName,drinkPrice,drinkDescription,file.replace("public\\","")],(error,result) => {
                if(error){
                    return res.status(403).json({erorr: "Failed To Insert Drinks"});
                }else{
                    return res.status(200).json({message:"Insert Successfully"})
                }
               
            })
        }

       
    } catch (error) {
        res.status(500).json({error:"Internal Error!"})
    }
})

router.get("/getDrinks",(req,res,next) => {
    db.query("SELECT * FROM MsDrinks LIMIT 3",(err,result) =>{
        if(err){
            return res.status(403).json({error:"Result Not Found!!"})
        }else{
            console.log(result)
            res.status(200).json(result)
        }
    })
})

router.get("/getAllDrinks",(req,res,next) => {
    db.query("SELECT * FROM MsDrinks",(err,result) => {
        if(err){
            return res.status(403).json({error:"Result Not Found!"})
        }else{
            res.status(200).json(result)
        }
    })
})

router.get('/getDrinkDetail/:drinkID', (req, res, next) => {
    const { drinkID } = req.params; 


    const query = 'SELECT * FROM MsDrinks WHERE DrinkID = ?';

    db.query(query, [drinkID], (error, result) => {
        if (error) {
            console.error('Database query error:', error); 
            return res.status(403).json({ message: 'Query error' }); 
        }

        if (result.length === 0) {
            return res.status(404).json({ message: 'Drink not found' });
        }

        return res.status(200).json(result[0]);
    });
});


module.exports = router