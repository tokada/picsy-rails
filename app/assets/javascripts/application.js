var saved = {};
saved.cell = [null, null];

$("td.ev").each(function(d){
  var re = $(this).attr("id").match(/ev-p(\d+)-p(\d+)/);
  if (!re) return false;
  $(this)
    .data("r", RegExp.$1)
    .data("c", RegExp.$2)
    .click(function(){
        // 評価行列の評価値セルクリック時
        if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
          // 前回固定したセルのハイライトを除去する
          $("#self-p"+saved.cell[0]).removeClass("btn-danger");
          $("#from-p"+saved.cell[0]).removeClass("btn-danger");
          $("#to-p"+saved.cell[1]).removeClass("btn-success");
          $("#ev-p"+saved.cell[0]+"-p"+saved.cell[1]).removeClass("btn-success");
          if (saved.cell[0] == $(this).data("r") && saved.cell[1] == $(this).data("c")) {
            // 固定したセルを再度クリックした際には固定解除し、取引値も消去する
            saved.cell = [null, null];
            $("#person-from").val("");
            $("#person-to").val("");
            $("#amount").val("");
          }
          else {
            // セル位置をグローバル変数に保存する
            saved.cell = [$(this).data("r"), $(this).data("c")];
            // 取引実行のプルダウン値（FromとTo）をセットする
            $("#person-from").val(saved.cell[0]);
            $("#person-to").val(saved.cell[1]);
            // 取引値をセットする（予算制約の10分の1）
            $("#amount").val(~~(parseInt($("#self-p"+saved.cell[0]).text())/10));
          }
        }
      })
    .hover(
      function(){
        // 評価行列の評価値セルマウスオーバー時
        if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
          // セルをハイライトする
          $(this).addClass("btn-success");
          $("#self-p"+$(this).data("r")).addClass("btn-danger");
          $("#from-p"+$(this).data("r")).addClass("btn-danger");
          $("#to-p"+$(this).data("c")).addClass("btn-success");
        }
      },function(){
        // 評価行列の評価値セルマウスアウト時
        if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
          // セルのハイライトを除去する（保存したセル位置のものは除く）
          if (saved.cell[0] != $(this).data("r") || saved.cell[1] != $(this).data("c")) {
            $(this).removeClass("btn-success");
          }
          if (saved.cell[0] != $(this).data("r")) {
            $("#self-p"+$(this).data("r")).removeClass("btn-danger");
            $("#from-p"+$(this).data("r")).removeClass("btn-danger");
          }
          if (saved.cell[1] != $(this).data("c")) {
            $("#to-p"+$(this).data("c")).removeClass("btn-success");
          }
        }
    });
});

// CSS切り替えとCookie保存
var select_theme = function(theme) {
	if (theme == null) return;
	var theme_enabled = false;
  $('link.theme').each(function(i) {
    if (this.id == "theme-"+theme) {
      this.disabled = true; // chromeで切り替わらないバグ回避
      this.disabled = false;
			theme_enabled = true;
    }
    else {
      this.disabled = true;
    }
  });
	if (!theme_enabled) {
		theme = "default";
		$('link#theme-default')[0].disabled = false;
	}
	$("li.select-theme").removeClass("disabled");
	$("li#select-theme-"+theme).addClass("disabled");
	$.cookie('theme', theme, { expires: 30, path: '/' });
};

$(function(){
  //select_theme($.cookie('theme'));
});

