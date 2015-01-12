<?php
if(isset($_POST['removeName'])) {
        $file_name = $_POST['removeName'];
        exec("rm /configs/$file_name");
}
?>
