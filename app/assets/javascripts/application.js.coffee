//= require jquery
//= require jquery_ujs
//= require jquery.cookie
//= require bootstrap
//= require rest_in_place

saved = {
  cell: [null, null]
}

$("td.ev").each (d) ->
  re = $(this).attr("id").match(/ev-p(\d+)-p(\d+)/)
  return false unless re
  $(this).data("r", RegExp.$1).data("c", RegExp.$2).click(->
    # 評価行列の評価値セルクリック時
    if $(this).data("c") > 0 and $(this).data("c") isnt $(this).data("r")
      # 前回固定したセルのハイライトを除去する
      $("#self-p" + saved.cell[0]).removeClass "btn-danger"
      $("#from-p" + saved.cell[0]).removeClass "btn-danger"
      $("#to-p" + saved.cell[1]).removeClass "btn-success"
      $("#ev-p" + saved.cell[0] + "-p" + saved.cell[1]).removeClass "btn-success"
      if saved.cell[0] is $(this).data("r") and saved.cell[1] is $(this).data("c")
        # 固定したセルを再度クリックした際には固定解除し、取引値も消去する
        saved.cell = [null, null]
        $("#person-from").val ""
        $("#person-to").val ""
        $("#amount").val ""
      else
        # セル位置をグローバル変数に保存する
        saved.cell = [$(this).data("r"), $(this).data("c")]
        # 取引実行のプルダウン値（FromとTo）をセットする
        $("#person-from").val saved.cell[0]
        $("#person-to").val saved.cell[1]
        # 取引値をセットする（予算制約の10分の1）
        $("#amount").val ~~(parseInt($("#self-p" + saved.cell[0]).text()) / 10)
  ).hover (->
    # 評価行列の評価値セルマウスオーバー時
    if $(this).data("c") > 0 and $(this).data("c") isnt $(this).data("r")
      # セルをハイライトする
      $(this).addClass "btn-success"
      $("#self-p" + $(this).data("r")).addClass "btn-danger"
      $("#from-p" + $(this).data("r")).addClass "btn-danger"
      $("#to-p" + $(this).data("c")).addClass "btn-success"
  ), ->
    # 評価行列の評価値セルマウスアウト時
    if $(this).data("c") > 0 and $(this).data("c") isnt $(this).data("r")
      # セルのハイライトを除去する（保存したセル位置のものは除く）
      $(this).removeClass "btn-success" if saved.cell[0] isnt $(this).data("r") or saved.cell[1] isnt $(this).data("c")
      unless saved.cell[0] is $(this).data("r")
        $("#self-p" + $(this).data("r")).removeClass "btn-danger"
        $("#from-p" + $(this).data("r")).removeClass "btn-danger"
      $("#to-p" + $(this).data("c")).removeClass "btn-success"  unless saved.cell[1] is $(this).data("c")

# アクターのHTMLを更新
get_person = (person_id, timeout) ->
  element1 = $("#from-p"+person_id+" .rest-in-place")
  element2 = $("#to-p"+person_id+" .rest-in-place")
  if element1.data("url-partial") != undefined
    setTimeout ->
      $.ajax(
        url: element1.data("url-partial"),
        type: "GET",
        dataType: "html",
        success: (data) ->
          element1.html(data)
          element2.html(data)
      )
    , timeout

# rest-in-placeの編集開始時に名前だけの文字列に書き換える
$('.rest-in-place').bind 'activate.rest-in-place', (event) ->
  $(this).text($(this).data("name"))

# rest-in-placeの編集キャンセル時にHTMLを再取得する
$('.rest-in-place').bind 'abort.rest-in-place', (event) ->
  if $(this).find("input").val().match("^@")
    get_person($(this).data("id"), 1)

# rest-in-placeの更新後にHTMLを再取得する
$('.rest-in-place').bind 'success.rest-in-place', (event, data) ->
  person_id = $(this).data("id")
  get_person(person_id, 1)
  $("option#person-from-p"+person_id).html(data.name)
  $("option#person-to-p"+person_id).html(data.name)

$ ->
  # CSS切り替えとCookie保存
  $("a[data-select-theme]").click ->
    theme = $(this).data("select-theme")
    return unless theme?
    theme_enabled = false
    $("link.theme").each (i) ->
      if @id is "theme-" + theme
        @disabled = true # chromeで切り替わらないバグ回避
        @disabled = false
        theme_enabled = true
      else
        @disabled = true
    unless theme_enabled
      theme = "default"
      $("link#theme-default")[0].disabled = false
    $("li.select-theme").removeClass "disabled"
    $("li#select-theme-" + theme).addClass "disabled"
    $.cookie "theme", theme,
      expires: 30
      path: "/"

