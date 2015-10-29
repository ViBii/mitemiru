var create_commit_graph = function(all_commit,own_commit,developer_name){
    var commit_count = [all_commit, own_commit];
    var developer_name = ['その他', developer_name];
    var color = ['#b1d7e8', '#006ab3'];

    // 取得データの一覧
    // developers: 開発者のリスト
    // commit_count: 各開発者のコミット数

    // 取得データサンプル(連携後に消去)
    var developers = ['DeveloperA', 'DeveloperB', 'DeveloperC', 'DeveloperD', '玄葉      条士郎'];
    var commit_count = [38, 56, 103, 11, 82];

    // グラフの色
    var base_color = '#4f81bd';
    var faint_color = '#749ccb';

    // SVG領域の設定
    var width = 960;
    var height = 640;
    var margin = {top: 0, right: 100, bottom: 0, left: 100};

    // SVG領域の描画
    var svg = d3.select("body")
          .append("svg")
          .attr("class", "commit_counter_graph")
          .attr("width", width)
          .attr("height", height);

    // SVG領域の確認
    svg.append("text")
      .text("Hello World")
      .attr({
        x: 150,
        y: 150
      })
      .attr("font-size", "50px");
}
