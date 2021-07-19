function transform(line) {
    var values = line.split(',');

    var obj = new Object();
    obj.Card_Type_Code = values[0];
    obj.Card_Type_Full_Name = values[1];
    obj.Issuing_Bank = values[2];
    obj.Card_Number = values[3];
    obj.Card_Holders_Name = values[4];
    obj.CVVCVV2 = values[5];
    obj.Issue_Date = values[6];
    obj.Expiry_Date = values[7];
    obj.Billing_Date = values[8];
    obj.Card_PIN = values[9];
    obj.Credit_Limit = values[10];
    var jsonString = JSON.stringify(obj);

    return jsonString;
}
