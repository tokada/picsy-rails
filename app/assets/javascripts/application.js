
var saved = {};
saved.cell = [null, null];

$("table.selectable tr").each(function(r){
  var row = r;
  $("td", this).each(function(d){
    var cell = d;
    $(this)
      .data("r", row)
      .data("c", cell-1)
      .click(function(){
				  // 評価行列の評価値セルクリック時
          if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
						// 前回固定したセルのハイライトを除去する
            $("#self-p"+saved.cell[0]).removeClass("alert-error");
            $("#from-p"+saved.cell[0]).removeClass("alert-error");
            $("#to-p"+saved.cell[1]).removeClass("alert-success");
            $("#ev-p"+saved.cell[0]+"-p"+saved.cell[1]).removeClass("alert-success");
						// セル位置をグローバル変数に保存する
						saved.cell = [$(this).data("r"), $(this).data("c")];
						// 取引実行のプルダウン値（FromとTo）をセットする
						$("#person-from").val(saved.cell[0]);
						$("#person-to").val(saved.cell[1]);
						// 取引値をセットする（予算制約の10分の1）
						$("#amount").val(~~(parseInt($("#self-p"+saved.cell[0]).text())/10));
          }
        })
      .hover(
        function(){
				  // 評価行列の評価値セルマウスオーバー時
          if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
						// セルをハイライトする
            $(this).addClass("alert-success");
            $("#self-p"+$(this).data("r")).addClass("alert-error");
            $("#from-p"+$(this).data("r")).addClass("alert-error");
            $("#to-p"+$(this).data("c")).addClass("alert-success");
          }
        },function(){
				  // 評価行列の評価値セルマウスアウト時
          if ($(this).data("c") > 0 && $(this).data("c") != $(this).data("r")) {
						// セルのハイライトを除去する（保存したセル位置のものは除く）
						if (saved.cell[0] != $(this).data("r") || saved.cell[1] != $(this).data("c")) {
							$(this).removeClass("alert-success");
						}
						if (saved.cell[0] != $(this).data("r")) {
							$("#self-p"+$(this).data("r")).removeClass("alert-error");
							$("#from-p"+$(this).data("r")).removeClass("alert-error");
						}
						if (saved.cell[1] != $(this).data("c")) {
							$("#to-p"+$(this).data("c")).removeClass("alert-success");
						}
          }
      });
  });
});

$(document).ready(function(){

});
