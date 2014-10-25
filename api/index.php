<?php
// set the models directory if needed
$modelsdir = '/var/www/yvytu/models';
$title = $_GET['q'];

$tmpfname = tempnam("/tmp", "yvy.");
$handle = fopen($tmpfname, "w");
fwrite($handle, "$title\n");
fclose($handle);

// use base2 or base 3 
$predicted =`cat $tmpfname | /usr/bin/dbacl -v -c $modelsdir/granizo -c $modelsdir/base1`;

if($predicted == "granizo\n"){
  echo $predicted;
}

unlink($tmpfname);
