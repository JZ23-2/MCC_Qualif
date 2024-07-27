const express = require("express");
var router = express.Router();
const db = require("../public/database/connect");
const hash= require("bcryptjs")
const checkUniqueEmail = require("../facade/checkUser")


router.post("/register",(req,res) => {
    const {email,username,password} = req.body
    const hashedPassword = hash.hashSync(password,8)

    checkUniqueEmail(email, (err,isUnique) =>{
        if(err){
            return res.status(500).json({error:'Database Query Failed'})
        }

        if(!isUnique){
            return res.status(403).json({error:'Email Must be Unique'})
        }

        if(!email.endsWith("@gmail.com")){
            return res.status(403).json({error:'Email Must end With @gmail.com'})
        }else{
            const query="INSERT INTO MsUsers (Username,Email,Password) VALUES (?,?,?)";
            db.query(query,[username,email,hashedPassword],(err,result)=>{
                if(err){
                    return res.status(500).json({error:'Database Query Failed'})
                }else{
                    res.status(200).json({message:'Registered Successfully!'})
                }
        
            })
        }
    })

   
})

router.post("/login", (req, res) => {
    var {email,password} = req.body
    console.log(req.body);
    
    const query = 'SELECT * FROM MsUsers WHERE Email = ?';
    db.query(query, [email], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Database query failed' });
        }else if(email === '' || password === ''){
            return res.status(403).json({error: "Field Mustn't be empty"})
        }else if(!email.endsWith("@gmail.com")){
            return res.status(403).json({error: 'Email Must End With @gmail.com'})
        }else if (result.length === 0) {
            return res.status(403).json({ error: 'Invalid User' });
        }else{
            const user = result[0];
            const passwordIsValid = hash.compareSync(password,user.Password)
            if(!passwordIsValid){
                return res.status(403).json({error:'Invalid Password'})
            }else{
                return res.status(200).json(
                    {message:'Login Success!',
                    data:user
                })
            }

        }
    });
});

module.exports = router;
