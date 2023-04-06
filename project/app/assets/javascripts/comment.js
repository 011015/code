let index;
let preId, preObj;
$(document).ready(function () {
    "use strict";
    $.fn.extend({
        insertAtCaret: function (myValue) {
            var $t = $(this)[0];
            if (document.selection) {
                this.focus();
                var sel = document.selection.createRange();
                sel.text = myValue;
                this.focus();
            } else if ($t.selectionStart || $t.selectionStart == '0') {
                var startPos = $t.selectionStart;
                var endPos = $t.selectionEnd;
                var scrollTop = $t.scrollTop;
                $t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
                this.focus();
                $t.selectionStart = startPos + myValue.length;
                $t.selectionEnd = startPos + myValue.length;
                $t.scrollTop = scrollTop;
            } else {
                this.value += myValue;
                this.focus();
            }
        }
    });
    $(".reply_button").click(function () {
        control(this);
    });
    $(".complaint_button").click(function () {
        control(this);
    });
    $(".report_button").click(function () {
        control(this);
    });

    $(".like_button").click(function () {
        if ($(this).text() === "取消点赞") {
            $(this).removeClass("button-active");
            $(this).text("点赞");
        } else {
            $(this).addClass("button-active");
            $(this).text("取消点赞");
        }
    });
    $(".collect_button").click(function () {
        if ($(this).text() === "取消收藏") {
            $(this).removeClass("button-active");
            $(this).text("收藏");
        } else {
            $(this).addClass("button-active");
            $(this).text("取消收藏");
        }
    });
    $(".Input_text").keyup(function () {
        let index = $(".Input_text").index($(this));
        let value = checkWord($(this));
        $(".tips_word").eq(index).html(value);
    });
    $(".imgBtn").click(function () {
        index = $(".imgBtn").index($(this));
        if ($(this).attr("isShowImg") === "false" || $(this).attr("isShowImg") === undefined) {
            $(this).attr("isShowImg", "true");
            let obj = $(this).parent().prev();
            obj.animate({marginTop: "-107px"}, 300);
            if (obj.children().length == 0) {
                for (var i = 0; i < ImgIputHandler.facePath.length; i++) {
                    obj.append("<img title=\"" + ImgIputHandler.facePath[i].faceName + "\" src=\"/assets/face/" + ImgIputHandler.facePath[i].facePath + "\" />");
                }
            }
            $(".faceDiv>img").unbind("click").click(function () {
                let obj = $(".Input_text").eq(index);
                obj.insertAtCaret("[" + $(this).attr("title") + "]");
                let value = checkWord(obj);
                $(".tips_word").eq(index).html(value);
                $(".imgBtn").eq(index).attr("isShowImg", "false");
                $(this).parent().animate({marginTop: "0px"}, 300);
            });
        } else {
            $(this).attr("isShowImg", "false");
            $(this).parent().prev().animate({marginTop: "0px"}, 300);
        }
    });
    ImgIputHandler.Init();
});

function checkWord(obj) {
    let len = obj.val().length;
    let max = obj.attr("maxlength");
    let value = max - len;
    if (value < 0) {
        value = 0;
    }
    return value;
}

function control(obj) {
    if (preObj !== obj && $(preId).is(':visible')) {
        $(preId).hide();
        let text = $(preObj).text();
        console.log(text[2] + text[3]);
        $(preObj).text(text[2] + text[3]);
        $(preObj).removeClass("button-active");
        if (index !== undefined) {
            $(".imgBtn").eq(index).attr("isShowImg", "false");
        }
    }

    let id = "#" + $(obj).val();
    if ($(id).is(':hidden')) {
        $(id).show();
        let obj1 = $(id).find(".Input_text");
        let obj2 = $(id).find(".postBtn");
        let text = $(obj).text();
        $(obj1[0]).attr("placeholder", text + "内容");
        $(obj2[0]).text(text);
        $(obj).text("取消" + text);
        $(obj).addClass("button-active");
    } else {
        $(id).hide();
        let text = $(obj).text();
        $(obj).text(text[2] + text[3]);
        $(obj).removeClass("button-active");
    }
    preId = id;    // Comment_Block_id
    preObj = obj;    // button
}

var ImgIputHandler = {
    facePath: [
        {faceName: "微笑", facePath: "0_微笑.gif"},
        {faceName: "撇嘴", facePath: "1_撇嘴.gif"},
        {faceName: "色", facePath: "2_色.gif"},
        {faceName: "发呆", facePath: "3_发呆.gif"},
        {faceName: "得意", facePath: "4_得意.gif"},
        {faceName: "流泪", facePath: "5_流泪.gif"},
        {faceName: "害羞", facePath: "6_害羞.gif"},
        {faceName: "闭嘴", facePath: "7_闭嘴.gif"},
        {faceName: "大哭", facePath: "9_大哭.gif"},
        {faceName: "尴尬", facePath: "10_尴尬.gif"},
        {faceName: "发怒", facePath: "11_发怒.gif"},
        {faceName: "调皮", facePath: "12_调皮.gif"},
        {faceName: "龇牙", facePath: "13_龇牙.gif"},
        {faceName: "惊讶", facePath: "14_惊讶.gif"},
        {faceName: "难过", facePath: "15_难过.gif"},
        {faceName: "酷", facePath: "16_酷.gif"},
        {faceName: "冷汗", facePath: "17_冷汗.gif"},
        {faceName: "抓狂", facePath: "18_抓狂.gif"},
        {faceName: "吐", facePath: "19_吐.gif"},
        {faceName: "偷笑", facePath: "20_偷笑.gif"},
        {faceName: "可爱", facePath: "21_可爱.gif"},
        {faceName: "白眼", facePath: "22_白眼.gif"},
        {faceName: "傲慢", facePath: "23_傲慢.gif"},
        {faceName: "饥饿", facePath: "24_饥饿.gif"},
        {faceName: "困", facePath: "25_困.gif"},
        {faceName: "惊恐", facePath: "26_惊恐.gif"},
        {faceName: "流汗", facePath: "27_流汗.gif"},
        {faceName: "憨笑", facePath: "28_憨笑.gif"},
        {faceName: "大兵", facePath: "29_大兵.gif"},
        {faceName: "奋斗", facePath: "30_奋斗.gif"},
        {faceName: "咒骂", facePath: "31_咒骂.gif"},
        {faceName: "疑问", facePath: "32_疑问.gif"},
        {faceName: "嘘", facePath: "33_嘘.gif"},
        {faceName: "晕", facePath: "34_晕.gif"},
        {faceName: "折磨", facePath: "35_折磨.gif"},
        {faceName: "衰", facePath: "36_衰.gif"},
        {faceName: "骷髅", facePath: "37_骷髅.gif"},
        {faceName: "敲打", facePath: "38_敲打.gif"},
        {faceName: "再见", facePath: "39_再见.gif"},
        {faceName: "擦汗", facePath: "40_擦汗.gif"},


    ]
    ,
    Init: function () {
        let objs = $(".Comment_content");
        for (let i = 0; i < objs.length; i++) {
            let text = $(objs[i]).html();
            text = text.replace(/\[微笑\]/g, '<img src="/assets/face/0_微笑.gif">');
            text = text.replace(/\[撇嘴\]/g, '<img src="/assets/face/1_撇嘴.gif">');
            text = text.replace(/\[色\]/g, '<img src="/assets/face/2_色.gif">');
            text = text.replace(/\[发呆\]/g, '<img src="/assets/face/3_发呆.gif">');
            text = text.replace(/\[得意\]/g, '<img src="/assets/face/4_得意.gif">');
            text = text.replace(/\[流泪\]/g, '<img src="/assets/face/5_流泪.gif">');
            text = text.replace(/\[害羞\]/g, '<img src="/assets/face/6_害羞.gif">');
            text = text.replace(/\[闭嘴\]/g, '<img src="/assets/face/7_闭嘴.gif">');
            text = text.replace(/\[大哭\]/g, '<img src="/assets/face/9_大哭.gif">');
            text = text.replace(/\[尴尬\]/g, '<img src="/assets/face/10_尴尬.gif">');
            text = text.replace(/\[发怒\]/g, '<img src="/assets/face/11_发怒.gif">');
            text = text.replace(/\[调皮\]/g, '<img src="/assets/face/12_调皮.gif">');
            text = text.replace(/\[龇牙\]/g, '<img src="/assets/face/13_龇牙.gif">');
            text = text.replace(/\[惊讶\]/g, '<img src="/assets/face/14_惊讶.gif">');
            text = text.replace(/\[难过\]/g, '<img src="/assets/face/15_难过.gif">');
            text = text.replace(/\[酷\]/g, '<img src="/assets/face/16_酷.gif">');
            text = text.replace(/\[冷汗\]/g, '<img src="/assets/face/17_冷汗.gif">');
            text = text.replace(/\[抓狂\]/g, '<img src="/assets/face/18_抓狂.gif">');
            text = text.replace(/\[吐\]/g, '<img src="/assets/face/19_吐.gif">');
            text = text.replace(/\[偷笑\]/g, '<img src="/assets/face/20_偷笑.gif">');
            text = text.replace(/\[可爱\]/g, '<img src="/assets/face/21_可爱.gif">');
            text = text.replace(/\[白眼\]/g, '<img src="/assets/face/22_白眼.gif">');
            text = text.replace(/\[傲慢\]/g, '<img src="/assets/face/23_傲慢.gif">');
            text = text.replace(/\[饥饿\]/g, '<img src="/assets/face/24_饥饿.gif">');
            text = text.replace(/\[困\]/g, '<img src="/assets/face/25_困.gif">');
            text = text.replace(/\[惊恐\]/g, '<img src="/assets/face/26_惊恐.gif">');
            text = text.replace(/\[流汗\]/g, '<img src="/assets/face/27_流汗.gif">');
            text = text.replace(/\[憨笑\]/g, '<img src="/assets/face/28_憨笑.gif">');
            text = text.replace(/\[大兵\]/g, '<img src="/assets/face/29_大兵.gif">');
            text = text.replace(/\[奋斗\]/g, '<img src="/assets/face/30_奋斗.gif">');
            text = text.replace(/\[咒骂\]/g, '<img src="/assets/face/31_咒骂.gif">');
            text = text.replace(/\[疑问\]/g, '<img src="/assets/face/32_疑问.gif">');
            text = text.replace(/\[嘘\]/g, '<img src="/assets/face/33_嘘.gif">');
            text = text.replace(/\[晕\]/g, '<img src="/assets/face/34_晕.gif">');
            text = text.replace(/\[折磨\]/g, '<img src="/assets/face/35_折磨.gif">');
            text = text.replace(/\[衰\]/g, '<img src="/assets/face/36_衰.gif">');
            text = text.replace(/\[骷髅\]/g, '<img src="/assets/face/37_骷髅.gif">');
            text = text.replace(/\[敲打\]/g, '<img src="/assets/face/38_敲打.gif">');
            text = text.replace(/\[再见\]/g, '<img src="/assets/face/39_再见.gif">');
            text = text.replace(/\[擦汗\]/g, '<img src="/assets/face/40_擦汗.gif">');
            $(objs[i]).html(text);
        }
        $(".Input_text").focusout(function () {
            $(this).parent().css("border-color", "#cccccc");
            $(this).parent().css("box-shadow", "none");
            $(this).parent().css("-moz-box-shadow", "none");
            $(this).parent().css("-webkit-box-shadow", "none");
        });
        $(".Input_text").focus(function () {
            $(this).parent().css("border-color", "rgba(19,105,172,.75)");
            $(this).parent().css("box-shadow", "0 0 3px rgba(19,105,192,.5)");
            $(this).parent().css("-moz-box-shadow", "0 0 3px rgba(241,39,232,.5)");
            $(this).parent().css("-webkit-box-shadow", "0 0 3px rgba(19,105,252,3)");
        });
    }
}