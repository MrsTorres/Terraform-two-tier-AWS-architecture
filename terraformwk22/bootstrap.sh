#!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>Hey there! Go refill your coffee. We have more to do!</h1></body></html>" > /var/www/html/index.html