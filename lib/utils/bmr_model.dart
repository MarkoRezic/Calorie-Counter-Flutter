abstract class BMRModel {
  double mCoeff, hCoeff, aCoeff, sCoeff;
  BMRModel({
    this.mCoeff = 0,
    this.hCoeff = 0,
    this.aCoeff = 0,
    this.sCoeff = 0,
  });

  int calculate(int mass, int height, int age) {
    return (mass * mCoeff + height * hCoeff + age * aCoeff + sCoeff).round();
  }
}

///Harris Benedict Original
class HBO extends BMRModel {
  HBO({
    mCoeff = 11.6575,
    hCoeff = 3.42645,
    aCoeff = 5.7153,
    sCoeff = 360.78425,
  }) : super(
          mCoeff: mCoeff,
          hCoeff: hCoeff,
          aCoeff: aCoeff,
          sCoeff: sCoeff,
        );

  HBO.male({
    mCoeff = 13.7516,
    hCoeff = 5.0033,
    aCoeff = 6.7550,
    sCoeff = 66.4730,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );

  HBO.female({
    mCoeff = 9.5634,
    hCoeff = 1.8496,
    aCoeff = 4.6756,
    sCoeff = 655.0955,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );
}

///Harris Benedict Revised
class HBR extends BMRModel {
  HBR({
    mCoeff = 11.6575,
    hCoeff = 3.42645,
    aCoeff = 5.7153,
    sCoeff = 360.78425,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );

  HBR.male({
    mCoeff = 13.397,
    hCoeff = 4.799,
    aCoeff = 5.677,
    sCoeff = 88.362,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );

  HBR.female({
    mCoeff = 9.247,
    hCoeff = 3.098,
    aCoeff = 4.330,
    sCoeff = 447.593,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );
}

///Mifflin St Jeor
class MSJ extends BMRModel {
  MSJ({
    mCoeff = 10.0,
    hCoeff = 6.25,
    aCoeff = 5.0,
    sCoeff = -75.0,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );

  MSJ.male({
    mCoeff = 10.0,
    hCoeff = 6.25,
    aCoeff = 5.0,
    sCoeff = 5.0,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );

  MSJ.female({
    mCoeff = 10.0,
    hCoeff = 6.25,
    aCoeff = 5.0,
    sCoeff = -161.0,
  }) : super(
    mCoeff: mCoeff,
    hCoeff: hCoeff,
    aCoeff: aCoeff,
    sCoeff: sCoeff,
  );
}
