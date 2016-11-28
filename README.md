# Firmata-samples
ロボットアームnanaboのFirmata/ruby用サンプルです。

# Usage

## Arduino

- 端末にArduino IDEをインストールする
- 端末とnanaboのArduinoをUSBケーブルで接続する
- Arduino IDEを立ち上げ、下記のとおり設定する
    - 「ツール」→「シリアルポート」で現在接続しているシリアルポートを選択
    - 「ツール」→「ボード」で「Arduino Due (Programming Port)」もしくは「Arduino Due (Native USB Port)」を選択
        - Portについてはシリアルポート欄に記述されている方に併せる
    - 「ファイル」→「スケッチの例」→「Firmata」→「StandardFirmata」を選択
- Arduino IDEのツールバーにある「→」ボタンを押下し、Arduinoへの書き込みを開始する

## サンプルプログラム
- 端末にruby/bundlerをインストールする
- リポジトリをクローンする
- 各種gemをインストールする
    `$ bundle install`
- rubyファイルを起動させる。第一引数がシリアルポート名（windowsならCOM番号）です
    `$ ruby main.rb COM3`

# Class/method

## Nanabo

nanaboを操作するためのコントロールクラスです

### Nanabo.new(serial_name)

コンストラクタです。

serial_name
:   シリアルポート名です

### Nanabo#offset

nanaboの各サーボの組み立ての際に生じた微妙な角度ズレを補正するための変数です（書き込みのみ）。  
要素7の配列を設定できます。

### Nanabo#speed

nanaboが動作するスピードを設定できます（読み書き可）。  
初期動作スピードは50で、100を設定するとその2倍の早さ、25ならその半分の早さになります。  
動作スピード50でサーボの移動量（各サーボで最大のもの）が45°の場合、移動におおよそ1秒程度掛かります。

### Nanabo#target_angles

次にnanaboが動作する際の、各サーボの目標角度を設定できます（読み書き可）。  
サーボは全部で7つあります。  
各サーボとも、0～180までの整数で指定してください。

### Nanabo#current_angles

現在のnanaboのサーボ角度が取得できます（読み込みのみ）。
サーボは全部で7つあります。  
各サーボとも、角度は0～180までの整数で記されます。

### Nanabo#holds_pitch

この設定値をtrueにすると、nanaboがどんな姿勢をとっても、バキュームポンプと地面のなす角が常に設定した値になります（読み書き可）。  
（ただし姿勢と設定角度によっては、一定を保てない場合もあります。また、サーボM3による角度変化は吸収できません）  
初期値はtrueです。

### Nanabo#pitch_angle

上記設定により設定される、バキュームポンプと地面がなす角度を設定できます（読み書き可）。  
-90～+90の整数で設定できます。  
バキュームポンプが真下を向くようにするには+90、真上を向くようにするには-90を設定します。  
Nanabo#holds_pitchがfalseの場合には、この設定値はnanaboの動作に影響しません。

### Nanabo#set_default_arm(length, angle)

次にnanaboが動作する際に、擬似極座標系で指定したlengthとangleを成すよう、サーボの角度を調整します。  
サーボM2の回転軸を基準点とし、そこからサーボM4の回転軸（≒バキュームの付け根）までを結んだ線分をrとします。  
このrの長さがlength(cm)、線分rと地面（と平行な線）がなす角φがangle(DEG)として指定できます。

### Nanabo#set_default_arm_xy(x, y, is_ground_base = true)

次にnanaboが動作する際に、擬似円筒座標系で指定したxとyを成すよう、サーボの角度を調整します。  
サーボM2の回転軸を基準点Oとし、サーボM4の回転軸を目標点Pとします。  
このPまでの距離の水平成分をx(cm)、垂直成分をy(cm)として指定できます。  
なお、is_ground_baseが真の場合、y=0、かつバキュームが真下を向いているとき、バキュームの先端部が接地するよう垂直成分を調整します。

### Nanabo#move

実際にnanaboを動作させます。  
nanaboの動作が完了するまで、このメソッドはプログラムをブロッキングします。

### Nanabo#vacuum

nanaboのバキュームポンプを操作するためのコントロールオブジェクトです。  
下記Vacuumクラスのメソッドが利用できます。

## Vacuum

nanaboのバキュームポンプを操作するためのコントロールクラスです。  
バキュームポンプを操作することで、nanaboが物を掴むことができます。

### Vacuum#suck

バキュームポンプの吸着を開始します。

### Vacuum#release

バキュームポンプの吸着を終了します。

### Vacuum#sucking?

バキュームポンプが吸着中である場合、trueを返します。

