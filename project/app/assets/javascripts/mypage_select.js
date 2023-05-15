let preId1 = "", preId2 = "";
let preObj1 = "", preObj2 = "";
$(function () {
    $(".select-header1").click(function () {
        let id = "#" + $(this).val();
        if ($(preId1).is(':visible')) {
            $(preId1).hide();
            if ($(preId2).is(':visible')) {
                $(preId2).hide();
                $(preObj2).removeClass("select-header-active");
            }
            $(preObj1).removeClass("select-header-active");
        }
        if ($(id).is(':hidden')) {
            $(id).show();
            $(this).addClass("select-header-active");
            preId1 = id;
            preObj1 = this;
        }
    });

    $(".select-header2").click(function () {
        let id = "#" + $(this).parent().attr("id") + "-" + $(this).val();
        if ($(preId2).is(':visible')) {
            $(preId2).hide();
            $(preObj2).removeClass("select-header-active");
        }
        if ($(id).is(':hidden')) {
            $(id).show();
            $(this).addClass("select-header-active");
            preId2 = id;
            preObj2 = this;
        }
    });
});