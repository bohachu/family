<?php session_start();?>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html><head>
<meta content="text/html; charset=big5" http-equiv="content-type">
<meta name="viewport" content="width=device-width, initial-scale=0.5">
<title>�a�a�ζ�L�n�~ ���ַӤ��j�Ҷ�</title>

<style type="text/css">
body { margin: 0px 0px 0px 0px; 
	background-image: url(image/background1136@2x.jpg);
	background-repeat: repeat;
}
input[type=checkbox] { 
	-webkit-transform: scale(2,2);
	-moz-transform: scale(2,2);
	-o-transform: scale(2,2);
}
/*
input[type=file] { 
	-webkit-transform: scale(2);
	-moz-transform: scale(2);
	-o-transform: scale(2);
}
*/

</style>
<script type="text/javascript">
	function changeNextButtonStatus() {
		if (document.agreement.checkbox.checked) {
			document.agreement.next.disabled = false;
		} else {
			document.agreement.next.disabled = true;
		}
	}
	function checkFile() {
		var uploadFile = document.getElementById('file').value;
		if (uploadFile == '') {
			alert("�п�ܤW�ǷӤ��I");
		} else {
			document.getElementById("agreementForm").submit();
		}
	}
</script>
</head>
<body>
	<div style="width:100%;" align="center">
		<br><br><br>
		<img style="width: 615px; height: 622px;" alt="" src="image/indexImage01.png"><br><br><br>
        <form method="post" action="../uploadFileWebapp.php" name="agreement" id="agreementForm" align="center" enctype="multipart/form-data">
		<span style="font-size:35px">�п�ܹζ�Ӥ��G</span><br><br><br>
        <input type="file" name="file" id="file">
		<br>
		<span style="font-size:20px; color:red;" >���ɮפW�ǻݭniOS 6.0�H�W�����䴩</span><br>
		<br><br><br>
        <input name="checkbox" id="agreement" onclick="changeNextButtonStatus()" type="checkbox">&nbsp;<label style="font-size:35px;" for="agreement">���H�P�N�N�Ӥ���ƨѧ@�Ш|���Ŷ�</label>
		<br>
		<br>
        <br>
        <br>
		<input style="font-size: 35px;"  disabled="disabled" name="next" value="�W�ǷӤ�" type="button" onClick="checkFile()">
		<input type="hidden" name="id" value="<?php echo session_id(); ?>"><br>
        <br>
		<br>
		<br>
		<br>
		</form>
	</div>
</body>
</html>