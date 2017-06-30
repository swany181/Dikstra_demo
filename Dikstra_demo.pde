import ddf.minim.*;

//Minim minim;  //Minim型変数であるminimの宣言
//AudioPlayer player;  //サウンドデータ格納用の変数

final int SIZE = 30;
final int nDOT = 20;

int[][] field;

int[][] map;
int [] map_x;
int [] map_y;

PImage[] images = new PImage[6];

//初期位置
float image_x = 8;
float image_y = 18;
float target_px = 8;
float target_py = 18;
float target_x = 8;
float target_y = 18;

boolean flag = false;

//int [] box_x = {
//  2, 8, 6, 7, 4, 17, 16
//};
//int [] box_y = {
//  6, 8, 3, 8, 9, 16, 7
//};

//迷路的に繁雑に置く

int [] box_x = {
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 7, 7, 8, 9, 10, 11, 12, 13, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 7, 6, 9, 10, 11, 12, 12, 12, 12, 12, 11, 10, 9, 8, 8, 0
};
int [] box_y = {
1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 17, 16, 16, 16, 16, 16, 15, 14, 13, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 15, 16, 12, 12, 12, 11, 10, 10, 9, 8, 7, 5, 5, 5, 5, 5, 6, 1
};


int [] boy_x = {
  12, 16, 17, 17
};
int [] boy_y = {
  6, 18, 18, 1
};
int [] girl_x = {
  5, 5, 18, 8
};
int [] girl_y = {
  7, 10, 16, 12
};
int [] gray_x = {
  8, 7, 18, 13
};
int [] gray_y = {
  7, 10, 11, 12
};

int line = 0;

void setup() {
  size(600, 600);

  //minim = new Minim(this);  //初期化
  //player = minim.loadFile("bgm.mp3"); //mp3ファイルを指定する 
  //player.play();  //再生

  field = new int[nDOT][nDOT];

  images[0] = loadImage( "back.png" );
  images[1] = loadImage( "ico_man7_1.gif" );
  images[2] = loadImage( "ico_box2_16.gif" );
  images[3] = loadImage( "ico_boy1_3.gif" );
  images[4] = loadImage( "ico_girl1_7.gif" );
  images[5] = loadImage( "ico_gray1_2.gif" );
  images[0].resize(nDOT*SIZE, nDOT*SIZE);
  for (int i=1; i<images.length; i++) {
    images[i].resize(SIZE, SIZE);
  }

  int nRoute = (nDOT-1)*(nDOT-1); // ルートの数
  map = new int[nDOT*nDOT][nDOT*nDOT]; // DOTの接続関係のマップ
  map_x = new int[nDOT*nDOT];
  map_y = new int[nDOT*nDOT];

  int num = 0;
  for (int x=0; x<nDOT; x++) { // DOTの状況を読み込む
    for (int y=0; y<nDOT; y++) {
      field[x][y] = num;
      map_x[num] = x;
      map_y[num] = y;
      num++;
    }
  }
  for (int i=0; i<nDOT*nDOT; i++) // 接続マップを初期化する
    for (int j=0; j<nDOT*nDOT; j++)
      map[i][j] = (i==j) ? 0 : -1;
  for (int x=0; x<nDOT; x++) { // DOTの状況を読み込む
    for (int y=0; y<nDOT; y++) {
      if (x+1<nDOT&&frow(x, y))map[field[x][y]][field[x+1][y]] = map[field[x+1][y]][field[x][y]] = 1;
      if (y+1<nDOT&&fcolumn(x, y))map[field[x][y]][field[x][y+1]] = map[field[x][y+1]][field[x][y]] = 1;
    }
  }
}

int v = 0;

void draw() {
  image(images[0], 0, 0);
  image(images[1], image_x*SIZE, image_y*SIZE);
  box();
  boy();
  girl();
  gray();

  stroke(255, 255, 255, line);
  for (int i=1; i<nDOT; i++) {
    line(i*SIZE, 0, i*SIZE, height);
    line(0, i*SIZE, width, i*SIZE);
  }

  int dst = field[(int)target_px][(int)target_py];  // 出発地点
  int src = field[(int)target_x][(int)target_y]; // 到着地点
  int[] distance = new int[nDOT*nDOT]; // 各DOTまでの最短距離
  int[] via = new int[nDOT*nDOT]; // 経由地
  dijkstra(map, src, distance, via);
  if (distance[dst]==Integer.MAX_VALUE) { // 解なし
    println("no route");
  } else {
    println("distance="+distance[dst]);

    int size = 0;
    for (int i=dst; i!=src; i=via[i]) {
      size++;
    }
    int [] save_i = new int [size+1];

    int j = 0;
    for (int i=dst; i!=src; i=via[i]) {
      print("(" + map_x[i] + "," + map_y[i] + ")");
      save_i[j] = i;
      j++;
    }
    println("(" + map_x[src] + "," + map_y[src] + ")");
    save_i[j] = src;

    if (flag) {
      if (map_x[save_i[v]]<=image_x) {
        image_x -= 0.2;
        if (map_x[save_i[v]]>image_x) {
          image_x=map_x[save_i[v]];
        }
      } else if (map_x[save_i[v]]>=image_x) {
        image_x += 0.2;
        if (map_x[save_i[v]]<image_x) {
          image_x=map_x[save_i[v]];
        }
      }
      if (map_y[save_i[v]]<=image_y) {
        image_y -= 0.2;
        if (map_y[save_i[v]]>image_y) {
          image_y=map_y[save_i[v]];
        }
      } else if (map_y[save_i[v]]>=image_y) {
        image_y += 0.2;
        if (map_y[save_i[v]]<image_y) {
          image_y=map_y[save_i[v]];
        }
      }
      if (image_x==map_x[save_i[v]]&&image_y==map_y[save_i[v]]) {
        v++;
        if (v==j+1) {
          v = 0;
          target_px = target_x;
          target_py = target_y;
          flag = false;
        }
      }
    }
    image(images[1], image_x*SIZE, image_y*SIZE);
  }
}

void mousePressed() {
  int x = mouseX/SIZE;
  int y = mouseY/SIZE;
  if (!flag&&fmouse(x, y)) {
    target_x = x;
    target_y = y;
    flag = true;
  }
}

void dijkstra(int[][] map, int src, int[] distance, int[] via) {
  int nTown = distance.length;
  boolean[] fixed = new boolean[nTown]; // 最短距離が確定したかどうか
  for (int i=0; i<nTown; i++) { // 各DOTについて初期化する
    distance[i] = Integer.MAX_VALUE; // 最短距離の初期値は無限遠
    fixed[i] = false; // 最短距離はまだ確定していない
    via[i] = -1;  // 最短経路の経由地は決っていない
  }
  distance[src] = 0;  // 出発地点までの距離を0とする
  while (true) {
    // 未確定の中で最も近いDOTを求める
    int marked = minIndex(distance, fixed);
    if (marked < 0) return; // 全DOTが確定した場合
    if (distance[marked]==Integer.MAX_VALUE) return; // 非連結グラフ
    fixed[marked] = true; // そのDOTまでの最短距離は確定となる
    for (int j=0; j<nTown; j++) { // 隣のDOT(i)について
      if (map[marked][j]>0 && !fixed[j]) { // 未確定ならば
        // マークしたDOTを経由した距離を求める
        int newDistance = distance[marked]+map[marked][j];
        // 今までの距離よりも小さければ、それを覚える
        if (newDistance < distance[j]) {
          distance[j] = newDistance;
          via[j] = marked; // 経由地を書き換える
        }
      }
    }
  }
}

int minIndex(int[] distance, boolean[] fixed) {
  int idx=0;
  for (; idx<fixed.length; idx++) // 未確定のDOTをどれか一つ探す
    if (!fixed[idx]) break;
  if (idx == fixed.length) return -1; // 未確定のDOTが存在しなければ-1
  for (int i=idx+1; i<fixed.length; i++) // 距離が小さいものを探す
    if (!fixed[i] && distance[i]<distance[idx]) idx=i;
  return idx;
}

void box() {
  for (int i=0; i<box_x.length; i++) {
    image(images[2], box_x[i]*SIZE, box_y[i]*SIZE);
  }
}
void boy() {
  for (int i=0; i<boy_x.length; i++) {
    image(images[3], boy_x[i]*SIZE, boy_y[i]*SIZE);
  }
}
void girl() {
  for (int i=0; i<girl_x.length; i++) {
    image(images[4], girl_x[i]*SIZE, girl_y[i]*SIZE);
  }
}
void gray() {
  for (int i=0; i<gray_x.length; i++) {
    image(images[5], gray_x[i]*SIZE, gray_y[i]*SIZE);
  }
}

void keyPressed() {
  if (key==' ') {
    line++;
    line=(line%2)*255;
  }
}

//void stop() {
//  player.close();  //サウンドデータを終了
//  minim.stop();
//  super.stop();
//}

boolean frow(int x, int y) {
  boolean f = true;
  for (int i=0; i<box_x.length; i++) {
    f = f&&!((x==box_x[i]||x+1==box_x[i])&&y==box_y[i]);
  }
  for (int i=0; i<boy_x.length; i++) {
    f = f&&!((x==boy_x[i]||x+1==boy_x[i])&&y==boy_y[i]);
  }
  for (int i=0; i<girl_x.length; i++) {
    f = f&&!((x==girl_x[i]||x+1==girl_x[i])&&y==girl_y[i]);
  }
  for (int i=0; i<gray_x.length; i++) {
    f = f&&!((x==gray_x[i]||x+1==gray_x[i])&&y==gray_y[i]);
  }
  return f;
}

boolean fcolumn(int x, int y) {
  boolean f = true;
  for (int i=0; i<box_x.length; i++) {
    f = f&&!(x==box_x[i]&&(y==box_y[i]||y+1==box_y[i]));
  }
  for (int i=0; i<boy_x.length; i++) {
    f = f&&!(x==boy_x[i]&&(y==boy_y[i]||y+1==boy_y[i]));
  }
  for (int i=0; i<girl_x.length; i++) {
    f = f&&!(x==girl_x[i]&&(y==girl_y[i]||y+1==girl_y[i]));
  }
  for (int i=0; i<gray_x.length; i++) {
    f = f&&!(x==gray_x[i]&&(y==gray_y[i]||y+1==gray_y[i]));
  }
  return f;
}

boolean fmouse(int x, int y) {
  boolean f = true;
  for (int i=0; i<box_x.length; i++) {
    f = f&&!(x==box_x[i]&&y==box_y[i]);
  }
  for (int i=0; i<boy_x.length; i++) {
    f = f&&!(x==boy_x[i]&&y==boy_y[i]);
  }
  for (int i=0; i<girl_x.length; i++) {
    f = f&&!(x==girl_x[i]&&y==girl_y[i]);
  }
  for (int i=0; i<gray_x.length; i++) {
    f = f&&!(x==gray_x[i]&&y==gray_y[i]);
  }
  return f;
}