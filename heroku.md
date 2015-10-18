
    在 http://heroku.com 上注册账号
    安装 heroku toolbelt

    在终端上登录 heroku，只需要验证一次，除非换机器，换帐号都不需要再登录。

    heroku login

    如果 ssh key 换了，需要重新添加

    heroku keys:add


    cd app
    heroku create

    这一步会提示一个 URL，也可以自己指定

    heroku create myapp

    这样会得到一个 http://myapp.herokuapp.com 的 URL

    为 heroku 添加一个专门部署的 branch。因为需要添加配置文件

    git checkout -b deploy
    cp config/settings.yml.example config/settings.yml
    git add --force config/settings.yml
    git commit -m 'Commit settings.yml for heroku'

    可以根据需要，更改 settings.yml 并提交。注意，因为可能包含帐号等私密信息， 请不要把此 deploy branch push 到任何公开的 git 仓库中。

    把 branch push 到 heroku

    git push -u heroku deploy:master

    成功后创建数据库

    heroku run rake db:setup

    访问 create 的时候给出的地址就可以了

    以后部署时，先将改动 merge 到 deploy，然后再 push 到 heroku

    git checkout deploy
    git merge master
    git push

    如果需要 migrate

    heroku run rake db:migrate

