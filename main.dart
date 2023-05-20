import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afet Hizli Kayit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}




class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

Future<bool> checkCredentials() async {
  try {
    final ftpConnect = FTPConnect('ftpupload.net',
        user: 'unaux_34139260', pass: 'mnk2jcccym');
    await ftpConnect.connect();
    await ftpConnect.changeDirectory('htdocs');
    final remoteFile = 'login.txt';

    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/$remoteFile');

    await ftpConnect.downloadFileWithRetry(remoteFile, localFile, pRetryCount: 2);

    final fileContent = await localFile.readAsString();
    final credentials = fileContent.trim().split('\n');

    for (final credential in credentials) {
      final parts = credential.split(':');
      if (parts.length == 2) {
        final username = parts[0];
        final password = parts[1];
        if (_usernameController.text == username &&
            _passwordController.text == password) {
          return true;
        }
      }
    }
    return false;
  } catch (e) {
    print('Hata: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bir hata oluştu.')),
    );
    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oturum Aç'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
              ),
              ElevatedButton(
                child: const Text('Oturum Aç'),
                onPressed: () async {
                  final isValid = await checkCredentials();
                  if (isValid) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hatalı kullanıcı adı veya şifre.')),
                    );
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Kayıt Ol'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<bool> registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      return false;
    }

    final ftpConnect = FTPConnect('ftpupload.net',
        user: 'unaux_34139260', pass: 'mnk2jcccym');
    await ftpConnect.connect();
    await ftpConnect.changeDirectory('htdocs');
    final remoteFile = 'login.txt';

    final directory = await getApplicationDocumentsDirectory();
    final localFile = File('${directory.path}/$remoteFile');

    await ftpConnect.downloadFileWithRetry(remoteFile, localFile, pRetryCount: 2);

    await localFile.writeAsString(
        '\n${_usernameController.text}:${_passwordController.text}\n',
        mode: FileMode.append);

    await ftpConnect.uploadFile(localFile);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
              ),
                            TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Şifreyi Tekrarla'),
                obscureText: true,
              ),
              ElevatedButton(
                child: const Text('Kayıt Ol'),
                onPressed: () async {
                  final isRegistered = await registerUser();
                  if (isRegistered) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kayıt başarılı!')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kayıt başarısız.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}







class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  

  @override
  // ignore: library_private_types_in_public_api 
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Afetzede> afetzedeler = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Afet Hizli Kayit'),
      ),
      body: ListView.builder(
        itemCount: afetzedeler.length,
        itemBuilder: (context, index) {
          final afetzede = afetzedeler[index];
          return ListTile(
            title: Text('${afetzede.ad} ${afetzede.soyad}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AfetzedeDetaySayfasi(afetzede: afetzede),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final yeniAfetzede = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const YeniAfetzedeEklemeSayfasi()),
          );
          if (yeniAfetzede != null) {
            setState(() {
              afetzedeler.add(yeniAfetzede as Afetzede);
            });
          }
        },
      ),
    );
  }
}

class AfetzedeDetaySayfasi extends StatelessWidget {
  final Afetzede afetzede;

  const AfetzedeDetaySayfasi({Key? key, required this.afetzede}) : super(key: key);


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${afetzede.ad} ${afetzede.soyad}'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yaş: ${afetzede.yas}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Cinsiyet: ${afetzede.cinsiyet}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Barınma: ${afetzede.barinma}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Beslenme: ${afetzede.beslenme}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Giyim: ${afetzede.giyim}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('T.C.: ${afetzede.saglikSorunlari}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Cep Telefon Numarası: ${afetzede.temelVitalBilgiler}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Kayıp Yakın Sayısı: ${afetzede.sosyalPsikolojikSorunlar}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Kan Grubu: ${afetzede.riskFaktorleri}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          
          ],
        ),
      ),
    );
  }
}





class Afetzede {
  final String id;
  final String ad;
  final String soyad;
  final String yas;
  final String cinsiyet;
  final String barinma;
  final String beslenme;
  final String giyim;
  final String saglikSorunlari;
  final String temelVitalBilgiler;
  final String sosyalPsikolojikSorunlar;
  final String riskFaktorleri;

  

  Afetzede({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.yas,
    required this.cinsiyet,
    required this.barinma,
    required this.beslenme,
    required this.giyim,
    required this.saglikSorunlari,
    required this.temelVitalBilgiler,
    required this.sosyalPsikolojikSorunlar,
    required this.riskFaktorleri,

    
  });
}

class YeniAfetzedeEklemeSayfasi extends StatefulWidget {
  const YeniAfetzedeEklemeSayfasi({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _YeniAfetzedeEklemeSayfasiState createState() => _YeniAfetzedeEklemeSayfasiState();
}

class _YeniAfetzedeEklemeSayfasiState extends State<YeniAfetzedeEklemeSayfasi> {
  final _formKey = GlobalKey<FormState>();

  String ad = '';
  String soyad = '';
  String yas = '';
  String cinsiyet = '';
  String barinma = '';
  String beslenme = '';
  String giyim = '';
  String saglikSorunlari = '';
  String temelVitalBilgiler = '';
  String sosyalPsikolojikSorunlar = '';
  String riskFaktorleri = '';
  
  


  Future<void> requestStoragePermission() async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    print('Depolama izni verildi');
  } else {
    print('Depolama izni reddedildi');
  }
}

Future<void> uploadFile() async {
  // İzinleri kontrol et ve iste
  final status = await Permission.storage.status;
  if (!status.isGranted) {
    await requestStoragePermission();
  }
}




TextEditingController _nameController = TextEditingController();
TextEditingController _surnameController = TextEditingController();
TextEditingController _ageController = TextEditingController();
TextEditingController _genderController = TextEditingController();
TextEditingController _shelterController = TextEditingController();
TextEditingController _nutritionController = TextEditingController();
TextEditingController _clothingController = TextEditingController();
TextEditingController _healthproblemsController = TextEditingController();
TextEditingController _basicvitalinformationsController = TextEditingController();
TextEditingController _socialproblemsController = TextEditingController();
TextEditingController _riskfactorsController = TextEditingController();
TextEditingController _konumUrl = TextEditingController();






Future<String> getirKonum() async {

  
  
  
  LocationPermission permission;

  // Konum hizmetlerinin açık olduğunu kontrol edin
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Konum hizmetleri devre dışı bırakıldı.');
  }

  // Konum iznini kontrol edin
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Konum izinleri kalıcı olarak reddedildi. Ayarları değiştirin.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Konum izinleri reddedildi. İzin vermek için ayarları değiştirin.');
    }
  }

  // Geçerli konumu alın
  Position position = await Geolocator.getCurrentPosition();

  // Google Maps URL'sini oluşturun
  return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
}


  


  


  



    // Sunucuya dosya yükleme işlemini gerçekleştiren fonksiyon
Future<void> uploadFileToFtp(BuildContext context) async {
  try {
    // FTP bağlantısı için ayarlar
    final ftpClient = FTPConnect(
      'ftpupload.net',
      user: 'unaux_34139260',
      pass: 'mnk2jcccym',
      port: 21,
    );

    // Sunucuya bağlan
    final bool connected = await ftpClient.connect();
    if (connected) {
      // Afetzede verilerini içeren bir dosya oluşturun
      final fileContent = "\nAfetzede Adı: ${_nameController.text}\nAfetzede Soyadı: ${_surnameController.text}\nAfetzede yaşı: ${_ageController.text}\nAfetzede Cinsiyeti: ${cinsiyet}\nBarınma Durumu: ${barinma}\nBeslenme durumu: ${beslenme}\nGiyim durumu: ${giyim}\nT.C.: ${_healthproblemsController.text}\nCep Telefon Numarası: ${_basicvitalinformationsController.text}\nKayıp Yakın Sayısı: ${_socialproblemsController.text}\nKan Grubu:  ${riskFaktorleri}\nAfetzedenin Konumu: ${_konumUrl.text}";
 // Afetzede verilerini buraya ekleyin
      final now = DateTime.now();
      final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = 'afetzede_$formattedDate.txt';

      // Uygulamanın belgeler dizinini alın ve dosyayı oluşturun
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(fileContent);

      // Dosyayı FTP sunucusuna yükleyin
      await ftpClient.changeDirectory('htdocs/afetzedeler');
      final bool uploaded = await ftpClient.uploadFile(file);
      if (uploaded) {
        print('Dosya başarıyla yüklendi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya başarıyla yüklendi!')),
        );
      } else {
        print('Dosya yüklenemedi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya yüklenemedi')),
        );
      }

      // FTP bağlantısını kapatın
      await ftpClient.disconnect();
    } else {
      print('Sunucuya bağlanılamadı');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sunucuya bağlanılamadı')),
      );
    }
  } catch (error) {
    print('Hata oluştu: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bir hata oluştu: $error')),
    );
  }
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Afetzede Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir ad girin';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    ad = value!;
                  },
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Soyad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir soyad girin';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    soyad = value!;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Yaş'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir yaş girin';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    yas = value!;
                  },
                ),
                
DropdownButtonFormField<String>(
  value: cinsiyet,  // başlangıçta seçili olan değeri belirler
  decoration: const InputDecoration(labelText: 'Cinsiyet'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir cinsiyet seçin';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      cinsiyet = value!;
    });
  },
  onSaved: (value) {
    cinsiyet = value!;
  },
  items: <String>['Kadın', 'Erkek'].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),


DropdownButtonFormField<String>(
  value: barinma,
  decoration: const InputDecoration(labelText: 'Barınma'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir barınma durumu seçin';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      barinma = value!;
    });
  },
  onSaved: (value) {
    barinma = value!;
  },
  items: <String>['Var', 'Yok'].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),
DropdownButtonFormField<String>(
  value: beslenme,
  decoration: const InputDecoration(labelText: 'Beslenme'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir beslenme durumu seçin';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      beslenme = value!;
    });
  },
  onSaved: (value) {
    beslenme = value!;
  },
  items: <String>['Var', 'Yok'].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),
DropdownButtonFormField<String>(
  value: giyim,
  decoration: const InputDecoration(labelText: 'Giyim'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir giyim durumu seçin';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      giyim = value!;
    });
  },
  onSaved: (value) {
    giyim = value!;
  },
  items: <String>['Var', 'Yok'].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),
                TextFormField(
                  controller: _healthproblemsController,
                  decoration: const InputDecoration(labelText: 'Afetzedenin T.C. Kimlik Numarası'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen Afetzedenin T.C. Kimlik numarasını yazın';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    saglikSorunlari = value!;
                  },
                ),
                TextFormField(
                  controller: _basicvitalinformationsController,
                  decoration: const InputDecoration(labelText: 'Afetzedenin cep telefonu numarası'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen afetzedenin cep telefonu numarasını yazın.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    temelVitalBilgiler = value!;
                  },
                ),
                TextFormField(
                  controller: _socialproblemsController,
                  decoration: const InputDecoration(labelText: 'Kayıp Yakın Sayısı'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen afetzedenin kayıp yakın sayısını yazın.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    sosyalPsikolojikSorunlar = value!;
                  },
                ),


                                TextFormField(
                                  enabled: false,
                  controller: _konumUrl,
                  decoration: const InputDecoration(labelText: 'Afetzedenin Konumu'),
                  
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Afetzedenin Konumu alınamadı';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    
                  },
                ),

DropdownButtonFormField<String>(
  value: riskFaktorleri,
  decoration: const InputDecoration(labelText: 'Afetzedenin Kan Grubu'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen Afetzedenin kan grubunu seçin.';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      riskFaktorleri = value!;
    });
  },
  onSaved: (value) {
    riskFaktorleri = value!;
  },
  items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                children: [
                  
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pop(
                          context,
                          Afetzede(
                            id: DateTime.now().toString(),
                            ad: ad,
                            soyad: soyad,
                            yas: yas,
                            cinsiyet: cinsiyet,
                            barinma: barinma,
                            beslenme: beslenme,
                            giyim: giyim,
                            saglikSorunlari: saglikSorunlari,
                            temelVitalBilgiler: temelVitalBilgiler,
                            sosyalPsikolojikSorunlar: sosyalPsikolojikSorunlar,
                            riskFaktorleri: riskFaktorleri,
                            
                            
                          ),
                        );
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                  const SizedBox(height: 10), // İki düğme arasında boşluk bırakın
                  ElevatedButton(
                    onPressed: () async {
                      await uploadFileToFtp(context); // "Sunucuya yükle" düğmesine basıldığında dosyayı yükle
                    },
                    child: const Text('Sunucuya Yükle'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
  onPressed: () async {
    try {
      String konumUrl = await getirKonum();

      _konumUrl.text = konumUrl;
      // 'konumUrl' değişkenini bir snackbar ile gösterin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konum URL: $konumUrl'),
          
        ),
      );
    } catch (e) {
      // Konum bilgileri alınamazsa bir hata mesajı gösterin
      print(e);
    }
  },
  child: const Text('Konumu Getir'),
),


                ],
              ),
            ),
          ],
        ),
      ),
        )

        )
    );
  
  
  }
}
