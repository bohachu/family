<?php session_start(); ?>
<?php
  $strPixelSize = "35px";
  $strUserAgent = $_SERVER['HTTP_USER_AGENT'];
  if (strpos($strUserAgent,"U;") != "" && strpos($strUserAgent,"GT-I9300") != "") {
    $strPixelSize = "20px";
  }
  ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta content="width=device-width, initial-scale=0.5" name="viewport">
<title>選擇領獎的家庭教育中心</title>

<style type="text/css">
body { margin: 0px 0px 0px 0px; height: 100%;
background-image: url(image/background1136@2x.jpg);
background-repeat: repeat;}
label {font-size: <?php echo $strPixelSize; ?>;}
input[type=radio] { 
	-webkit-transform: scale(2,2);
	-moz-transform: scale(2,2);
	-o-transform: scale(2,2);
}
</style>
<script type="text/javascript">
    var lstCenterInfo = [
      {"name":"", "tel":"", "fax":"", "address":""},
      {"name":"臺北市家庭教育中心", "tel":"02-25419690", "fax":"02-25418752", "address":"臺北市中山區吉林路110號5樓"},
      {"name":"新北市家庭教育中心", "tel":"02-22724881", "fax":"02-22724882", "address":"新北市板橋區僑中一街1-1號4樓"},
      {"name":"高雄市家庭教育中心", "tel":"07-2153918",  "fax":"07-2157407",  "address":"高雄市前金區中正四路209號"},
      {"name":"基隆市家庭教育中心", "tel":"02-24271724", "fax":"02-24226632", "address":"基隆市信一路181號"},
      {"name":"桃園縣家庭教育中心", "tel":"03-3323885",  "fax":"03-3333063",  "address":"桃園市莒光街1號"},
      {"name":"新竹縣家庭教育中心", "tel":"03-6571045",  "fax":"03-6571046",  "address":"新竹縣竹北市縣政二路620號"},
      {"name":"新竹市家庭教育中心", "tel":"03-5325885",  "fax":"03-5350812",  "address":"新竹市東大路2段15巷1號2樓"},
      {"name":"苗栗縣家庭教育中心", "tel":"037-350746",  "fax":"037-377350",  "address":"苗栗市國華路1121號"},
      {"name":"臺中市家庭教育中心", "tel":"04-22298885", "fax":"04-22296885",  "address":"臺中市北區太平路70號"},
      {"name":"彰化縣家庭教育中心", "tel":"04-7261827",  "fax":"04-7275025",  "address":"彰化市中山路二段678號"},
      {"name":"南投縣家庭教育中心", "tel":"049-2243894", "fax":"049-2239924", "address":"南投市中興路669號"},
      {"name":"雲林縣家庭教育中心", "tel":"05-5346885",  "fax":"05-5345207",  "address":"雲林縣斗六市南揚街60號"},
      {"name":"嘉義縣家庭教育中心", "tel":"05-3620747",  "fax":"05-3623658",  "address":"嘉義縣太保市祥和二路東段8號"},
      {"name":"嘉義市家庭教育中心", "tel":"05-2754334",  "fax":"05-2777918",  "address":"嘉義市東區山子頂269-1號"},
      {"name":"臺南市家庭教育中心", "tel":"06-6591068",  "fax":"06-2215349",  "address":"臺南市中西區公園路127號"},
      {"name":"屏東縣家庭教育中心", "tel":"08-7378465",  "fax":"08-7381354",  "address":"屏東市華正路80號"},
      {"name":"宜蘭縣家庭教育中心", "tel":"03-9333837",  "fax":"03-9356118",  "address":"宜蘭市民權路一段36號1樓"},
      {"name":"花蓮縣家庭教育中心", "tel":"03-8569692",  "fax":"03-8461741",  "address":"花蓮市達固湖灣大路1號"},
      {"name":"臺東縣家庭教育中心", "tel":"089-341149",  "fax":"089-352594",  "address":"台東市中華路二段17號"},
      {"name":"澎湖縣家庭教育中心", "tel":"06-9262085",  "fax":"06-9266632",  "address":"澎湖縣馬公市自立路21號"},
      {"name":"連江縣家庭教育中心", "tel":"083-625171",  "fax":"083-625582",  "address":"馬祖南竿鄉介壽村76號"},
      {"name":"金門縣家庭教育中心", "tel":"082-312843",  "fax":"082-324457",  "address":"金門縣金城鎮民生路60號"},
      {"name":"原臺中縣家庭教育中心", "tel":"04-25285885", "fax":"04-25206356", "address":"臺中縣豐原市圓環東路782號4樓"},
      {"name":"原臺南縣家庭教育中心", "tel":"06-6569885",  "fax":"06-6592818",  "address":"臺南縣新營市秦漢街118號2樓"},
      {"name":"原高雄縣家庭教育中心", "tel":"07-2153918",  "fax":"07-2157407",  "address":"高雄市前金區中正四路209號4樓"}
      ];
  function confirmCenterInfo(intId) {
    var mssage = "您選擇的兌獎地點是\n" + lstCenterInfo[intId]["name"] + "\n\n"
            + "電話：" + lstCenterInfo[intId]["tel"] + "\n"
            + "地址：" + lstCenterInfo[intId]["address"];
    var isOk = confirm(mssage);
    if (isOk) {
      document.getElementById("postTarget").value = lstCenterInfo[intId]["name"];
      document.getElementById("CenterListForm").submit();
    }
  }
</script>
</head>
<body>
  <div align="center">
  <br>
    <div style="font-size: <?php echo $strPixelSize; ?>; color: rgb(204, 0, 0); font-weight: bold;">
    請選擇領獎的家庭教育中心
    </div>
        <br>
    <br>
    <table style="width: 70%;" border="0" cellpadding="3" cellspacing="5">
    <tbody>
    <tr>
    <td style="width: 5%;">
        <input  checked="checked" class="inputRadio" name="targetedu"id="option1" value="1" type="radio" onClick="confirmCenterInfo(1)"></td>
    <td style="width: 891px;"><label  for="option1">臺北市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option2" value="2" type="radio" onClick="confirmCenterInfo(2)"></td>
    <td style="width: 891px;"><label  for="option2">新北市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option3" value="3" type="radio" onClick="confirmCenterInfo(3)"></td>
    <td style="width: 891px;"><label  for="option3">高雄市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option4" value="4" type="radio" onClick="confirmCenterInfo(4)"></td>
    <td style="width: 891px;"><label  for="option4">基隆市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option5" value="5" type="radio" onClick="confirmCenterInfo(5)"></td>
    <td style="width: 891px;"><label  for="option5">桃園縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option6" value="6" type="radio" onClick="confirmCenterInfo(6)"></td>
    <td style="width: 891px;"><label  for="option6">新竹縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option7" value="7" type="radio" onClick="confirmCenterInfo(7)"></td>
    <td style="width: 891px;"><label  for="option7">新竹市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option8" value="8" type="radio" onClick="confirmCenterInfo(8)"></td>
    <td style="width: 891px;"><label  for="option8">苗栗縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option9" value="9" type="radio" onClick="confirmCenterInfo(9)"></td>
    <td style="width: 891px;"><label  for="option9">臺中市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option10" value="10" type="radio" onClick="confirmCenterInfo(10)"></td>
    <td style="width: 891px;"><label  for="option10">彰化縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option11" value="11" type="radio" onClick="confirmCenterInfo(11)"></td>
    <td style="width: 891px;"><label  for="option11">南投縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option12" value="12" type="radio" onClick="confirmCenterInfo(12)"></td>
    <td style="width: 891px;"><label  for="option12">雲林縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option13" value="13" type="radio" onClick="confirmCenterInfo(13)"></td>
    <td style="width: 891px;"><label  for="option13">嘉義縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option14" value="14" type="radio" onClick="confirmCenterInfo(14)"></td>
    <td style="width: 891px;"><label  for="option14">嘉義市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option15" value="15" type="radio" onClick="confirmCenterInfo(15)"></td>
    <td style="width: 891px;"><label  for="option15">臺南市家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option16" value="16" type="radio" onClick="confirmCenterInfo(16)"></td>
    <td style="width: 891px;"><label  for="option16">屏東縣家庭教育中心</label></td>
    </tr>

    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option17" value="17" type="radio" onClick="confirmCenterInfo(17)"></td>
    <td style="width: 891px;"><label  for="option17">宜蘭縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option18" value="18" type="radio" onClick="confirmCenterInfo(18)"></td>
    <td style="width: 891px;"><label  for="option18">花蓮縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option19" value="19" type="radio" onClick="confirmCenterInfo(19)"></td>
    <td style="width: 891px;"><label  for="option19">臺東縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option20" value="20" type="radio" onClick="confirmCenterInfo(20)"></td>
    <td style="width: 891px;"><label  for="option20">澎湖縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option21" value="21" type="radio" onClick="confirmCenterInfo(21)"></td>
    <td style="width: 891px;"><label  for="option21">連江縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option22" value="22" type="radio" onClick="confirmCenterInfo(22)"></td>
    <td style="width: 891px;"><label  for="option22">金門縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option23" value="23" type="radio" onClick="confirmCenterInfo(23)"></td>
    <td style="width: 891px;"><label  for="option23">原臺中縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option24" value="24" type="radio" onClick="confirmCenterInfo(24)"></td>
    <td style="width: 891px;"><label  for="option24">原臺南縣家庭教育中心</label></td>
    </tr>
    <tr>
    <td style="width: 5%;">
        <input  class="inputRadio" name="targetedu" id="option25" value="25" type="radio" onClick="confirmCenterInfo(25)"></td>
    <td style="width: 891px;"><label  for="option25">原高雄縣家庭教育中心</label></td>
    </tr>
    </tbody>
    </table>
<form method="post" action="../setTarget.php" id="CenterListForm">
  <input type="hidden" name="id" id="postId" value="<?php echo session_id(); ?>" />
  <input type="hidden" name="target" id="postTarget" value="" />
</form>
<br>
<br>
<br>
<br>
</div>
</body></html>​