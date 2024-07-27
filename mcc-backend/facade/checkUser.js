var express = require("express")
const db = require("../public/database/connect")

function checkUniqueEmail(email,callback){
    var query = "SELECT * FROM MsUsers";

    db.query(query, (err,result) => {
        if(err){
            return(callback(err,null));
        }
        let isUnique = true;
        result.forEach((row) => {
            if(row.Email == email){
                isUnique = false;
            }
        })

        callback(null,isUnique)
    })
}

module.exports = checkUniqueEmail