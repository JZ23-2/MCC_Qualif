var express = require("express");
var router = express.Router();
var db = require("../public/database/connect");


router.get("/getAllReview/:drinkID/",(req,res,next) => {
    const {drinkID} = req.params;

    const query = `SELECT *
                    FROM MsReview mr
                    JOIN MsDrinks md ON mr.DrinkID = md.DrinkID
                    JOIN MsUsers mu ON mu.UserID = mr.UserID
                    WHERE md.DrinkID = ?`

    db.query(query,[drinkID],(error,result) =>{
        if(error){
            return res.status(403).json({error:"Result Not Found"})
        }else{
            return res.status(200).json({data:result})
        }
    })
})

router.post("/giveReview",(req,res) => {
    var {userID,drinkID,reviewContent} = req.body;


    const query = `INSERT INTO MsReview (UserID,DrinkID,ReviewContent) VALUES (?,?,?)`

    db.query(query,[userID,drinkID,reviewContent],(err,result) => {
        if(userID === "" || drinkID === "" || reviewContent === "" ){
            return res.status(403).json({error:"Field Mustn't be Empty"})
        }
        
        if(err){
            return res.status(403).json({error:"Something Wrong"})
        }else{
            return res.status(200).json({message:"Review Success"})
        } 
    })
})

router.delete("/deleteReview/:reviewID/",(req,res) => {
    const {reviewID} = req.params;

    const query = "DELETE FROM MsReview WHERE ReviewID = ?"
    db.query(query,[reviewID],(err,result) => {
        if(err){
            return res.status(403).json({error:"Deleted Failed"})
        }else{
            return res.status(200).json({message:"Deleted Success"})
        }
    })
})

router.put("/updateReview/:reviewID/",(req,res) => {
    const {reviewID} = req.params;
    const {reviewContent} = req.body
    console.log(reviewID,reviewContent)

    const query = "UPDATE MsReview SET ReviewContent = ? WHERE ReviewID = ?"
    db.query(query,[reviewContent,reviewID],(err,result) => {
        if(reviewContent === ""){
            return res.status(403).json({error:"Field Mustn't be Empty"})
        }

        if(err){
            return res.status(403).json({message:"Failed To Update"})
        }else{
            return res.status(200).json({message:"Update Success"})
        }
    })
})

module.exports = router