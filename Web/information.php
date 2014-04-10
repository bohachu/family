<?php session_start();?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head>
<meta content="text/html; charset=big5" http-equiv="content-type">
<meta name="viewport" content="width=device-width, initial-scale=0.5"><title>資料填寫</title>

<script type="text/javascript">
	function changeNextButtonStatus() {
		if (document.agreement.checkbox.checked) {
			document.agreement.next.disabled = false;
		} else {
			document.agreement.next.disabled = true;
		}
	}
	function checkForm() {
		var phoneValue = document.getElementById('phone').value;
		var emailValue = document.getElementById('email').value;
		if (phoneValue == "") {
			alert("請輸入手機號碼！");
		} else if (emailValue == "") {
			alert("請輸入 Email！");
		} else {
			document.getElementById("AgreementForm").submit();
		}
	}
</script>
<style type="text/css">
body { 
	margin: 0px 0px 0px 0px;
	background-image: url(image/background1136@2x.jpg); 
}
input[type=checkbox] { 
	-webkit-transform: scale(2,2);
	-moz-transform: scale(2,2);
	-o-transform: scale(2,2);
}
</style>
</head>
<body>
	<br>
	<div align="center">
		<div style="background-image: url(image/informationImage01.png); background-repeat: no-repeat; width: 628px;">
        <br>
			<div style="width: 550px;" align="left"><big style="color: rgb(153, 0, 0);"><br>
			<big><big><big>恭喜符合抽獎資格，請填寫以下資料供活動通知與兌獎。</big></big></big></big>
            <br><br>
			<form method="post" action="../userInfoWebapp.php" name="agreement" id="AgreementForm">
			<table style="text-align: left; width: 550px; height: 60px;" border="0" cellpadding="2" cellspacing="2">
			<tbody>
			<tr>
			<td style="width: 30%; font-size: 35px; text-align: right; color: rgb(0, 102, 0);">手機號碼</td>
			<td><input maxlength="10" name="phone" id="phone" style="height: 35px; width: 90%;"></td>
			</tr>
			<tr>
			<td style="font-size: 35px; text-align: right; color: rgb(0, 102, 0);">Email</td>
			<td><input name="email" id="email" style="height: 35px; width: 90%;"></td>
			</tr>
			<tr>
			<td></td>
			<td><input name="isReceiveEpaper" value="1" id="isReceiveEpaper" type="checkbox">
            <label for="isReceiveEpaper" style="font-size: 30px; color: rgb(204, 0, 0); font-weight: bold;">訂閱電子報</label></td>
			</tr>
			</tbody>
			</table>
			<div align="center">
			<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
			<input name="checkbox" id="agreement" onclick="changeNextButtonStatus()" type="checkbox">			
            <label for="agreement" style="font-size: 30px;">本人同意主辦單位運用本人個資於活動聯絡及訊息通知</label>
            <br><br><br>
			<input style="font-size: 30px;" disabled="disabled" name="next" value="立即抽獎" type="button" onClick="checkForm()"><br>
			<input type="hidden" name="id" value="<?php echo session_id(); ?>"><br>
			</div>
			<br><br><br>
			</form>
			</div>
		</div>
	</div>
</body>
</html>