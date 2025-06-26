<?php
// php -S localhost:8090
// php chatDoc.php  生成 /chatDoc/chatDoc.json 文件
// index.html 和 chatDoc目录 配合使用
// $dir = "./chatDoc"; // 目录名
$dir = "./"; // 目录名
// 获取目录下所有文件
$files = scandir($dir);
// 遍历目录下所有文件
$data = array();
foreach ($files as $file) {
    // 排除隐藏文件
    if(in_array($file, array(".","..","chatDoc.php", "chatDoc.json"))){
        continue;
    }
    // 输出文件名 // 去掉后缀名
    $file = str_replace('.md', '', $file);
    // urlencode 防止中文乱码
    $file = urlencode($file);
    $data['data'][] = [
        'title'=>$file,
        'url'=>'?chatDoc='. $file
    ];
}
$data['count'] = count($data['data']);
// 输出json数据
header('Content-Type: application/json');
echo json_encode($data);
$file = $dir."chatDoc.json";
file_put_contents($file, json_encode($data));