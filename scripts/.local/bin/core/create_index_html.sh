#!/bin/bash
create_index_html() {
    local FOLDER_NAME=$1
    cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$FOLDER_NAME</title>
    <link rel="stylesheet" href="main.css">
</head>
<body>
    <h1>Welcome to $FOLDER_NAME</h1>
    <script src="main.js"></script>
</body>
</html>
EOF
}
