$(".show-button").click(function () {
    if ($(this).text() === '显示密码') {
        $("input[name=密码]").attr('type','text');
        $(this).text('隐藏密码');
        $(this).addClass('button-active');
    } else {
        $("input[name=密码]").attr('type','password');
        $(this).text('显示密码');
        $(this).removeClass('button-active');
    }
});

$(".show-button2").click(function () {
    if ($(this).text() === '显示密码') {
        $("#manipulator_密码").attr('type','text');
        $(this).text('隐藏密码');
        $(this).addClass('button-active');
    } else {
        $("#manipulator_密码").attr('type','password');
        $(this).text('显示密码');
        $(this).removeClass('button-active');
    }
});