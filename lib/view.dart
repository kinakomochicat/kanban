import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

final names = ['👀 観たい', '🎬 鑑賞中', '🎞️ 観終わった'];
final labels = ['未', '鑑賞中', '完了'];
final colors = [Colors.blue.shade50, Colors.orange.shade50, Colors.green.shade50];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();

  String keyword = '';

  void add() {
    widget.vm.add(input.text);
    input.clear();
  }

  Future<void> edit(Task t) async {
    var text = t.title;
    final result = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('タイトルを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, text),
            child: Text('保存'),
          ),
        ],
      ),
    );
    if (result != null) widget.vm.rename(t, result);
  }

  // ランダム
  void pickRandom() {
    final movie = widget.vm.pickRandom();

    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          movie == null ? '映画を追加しよう' : '🍿 次の一本は…',
        ),
        content: Text(
          movie == null
              ? 'まだ観ていない映画を追加すると、一本選べます。'
              : movie.title,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('閉じる'),
          ),
          if (movie != null && movie.status == 0)
            FilledButton(
              onPressed: () {
                widget.vm.move(movie, 1);
                Navigator.pop(c);
              },
              child: Text('鑑賞中に追加'),
            ),
        ],
      ),
    );
  }

  // 評価
  Widget stars(Task t) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$iつ星',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 48,
            ),
            icon: Icon(
              i <= t.star ? Icons.star : Icons.star_border,
              color: Colors.amber.shade700,
            ),
            onPressed: () => widget.vm.rate(t, i),
          ),
      ],
    );
  }

  Widget taskCard(Task t) {
    final s = t.status;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.title, style: TextStyle(fontSize: 16)),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => edit(t),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => widget.vm.remove(t),
                ),
              ],
            ),

            if (s == 2) stars(t),

            Wrap(
              spacing: 4, runSpacing: 4,
              children: [
                if (s > 0)
                  TextButton(
                    onPressed: () => widget.vm.move(t, s - 1),
                    child: Text('← ${labels[s - 1]}へ'),
                  ),
                if (s < 2)
                  FilledButton(
                    onPressed: () => widget.vm.move(t, s + 1),
                    child: Text('${labels[s + 1]}へ →'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget lane(int s) {
    final movies = widget.vm.search(keyword);

    final cards = [
      for (final t in movies)
        if (t.status == s) taskCard(t),
    ];
    return SizedBox(
      width: 300,
      child: Card(
        color: colors[s],
        child: Column(children: [
          ListTile(
            title: Text(names[s]),
            trailing: Text('${cards.length}件'),
          ),
          Expanded(child: ListView(children: cards)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '気になる作品をメモ',
        hintText: '映画、ドラマ、アニメなんでもOK',
        border: OutlineInputBorder(),
      ),
    );
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('観たいリストに追加'),
      ),
    );
    final entry = Card(child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(children: [
        field,
        Align(alignment: Alignment.centerRight, child: button),
      ]),
    ));
    // 検索
    final searchField = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'タイトルで検索',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            keyword = value;
          });
        },
      ),
    );
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'これまでに ${widget.vm.watchedCount()} 本鑑賞',
                  ),
                ),
                TextButton.icon(
                  onPressed: pickRandom,
                  icon: Icon(Icons.shuffle),
                  label: Text('一本選ぶ'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (int s = 0; s < 3; s++) lane(s),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('🍿 movies')),
      body: Column(children: [
        entry,
        searchField,
        Expanded(child: board),
      ]),
    );
  }
}