class Data {
  Data(this.name, this.value, this.index);
  final String name;
  final double value;
  final double index;
}

class Setting {
  Setting(this.hasJoysticks, this.hasCommand);
  bool hasJoysticks;
  bool hasCommand;
}
