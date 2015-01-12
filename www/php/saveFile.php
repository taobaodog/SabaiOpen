<?php
if(isset($_POST['loadFile'])) {
        $file_name = $_POST['loadFile'];
        $pathToFile = '/configs/'.$file_name;
        echo $pathToFile;
}
?>
