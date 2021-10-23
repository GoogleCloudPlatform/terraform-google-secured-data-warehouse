/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
