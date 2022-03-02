# CalorieCounter

FSRE student mobile application project made with Flutter and NodeJS.

# Instalacija i pokretanje projekta

Preduvjeti:
- instaliran Node.js i npm (potrebno samo za lokalno pokretanje backenda)
- instaliran Flutter
- instaliran Android Studio
- Android Emulator ili Fizièki Android ureðaj spojen USB-om
- postavljen API_BASE_URL u .env datoteci na heroku NodeJS aplikaciju ili na lokalni backend
- Moguæe je i samo preuzimanje i instalacija .apk datoteke na android ureðaju, ili .ipa za iOS, backend je pokrenut na heroku NodeJS aplikaciji

# Pokretanje frontenda
- u Android Studio otvoriti root folder projekta, smjestiti `.env` datoteku uz postavljenu `API_BASE_URL` na backend koji æe se koristiti
- za lokalni backend u .env upisati `API_BASE_URL=http://localhost:3000`, a za backend na heroku link od aplikacije (primjer .env datoteke je .env.example)
- pokrenuti Emulator ili spojiti Android ureðaj USB-om, dopustiti na ureðaju otklanjanje pogrešaka putem USB-a (debugiranje) unutar opcija za razvojne programere
- u Android studiju odraditi Run za main.dart file smjesten unutar /lib foldera, eventualno podesiti Run konfiguraciju na Run > Edit Configurations... i odabrati main.dart
- nakon pokretanja se generira /build folder
- Aplikacija bi se trebala instalirati i pokrenuti na ureðaju
- Izgenerirana .apk datoteka se nalazi u /build/app/outputs/flutter-apk/app.apk
- Po defaultu se generira "debug" verzija, ukoliko je potrebna release verzija (puno brža i služi za produkciju), može se izgenerirati sa `flutter build apk`, ova apk æe se nalaziti unutar /build/app/outputs/flutter-apk/app-release.apk

# Pokretanje backenda
- za lokalni backend preuzeti git repozitorij https://github.com/MarkoRezic/Calorie-Counter-NodeJS
- u root folderu smjestiti .env datoteku i popuniti podatke za bazu i JWT hash kao što je navedeno u .env.example
- pokrenuti lokalni backend u terminalu sa `npm start` iz root foldera od backend projekta (za heroku poslužitelj nisu potrebni nikakvi koraci)
- nije potreban pokrenut MySQL, baza je na heroku poslužitelju te ju i lokalni backend takoðer koristi
- ukoliko je potrebno i lokalnu bazu napraviti, potrebno je schemu kreirati i promijeniti podatke za spajanje unutar root foldera od backenda `.env` datoteci

# Instalacija gotove aplikacije
- u root folderu ovog repozitorija se nalazi i app-release.apk èijom instalacijom se može odmah koristiti aplikacija (Android ureðaji)

# Korištenje barkod skenera
- zakorištenje skenera potrebno je dati dozvolu korištenja kamere na ureðaju
- potreban je fizièki ureðaj, emulatori ne podržavaju ovu opciju 

## App screenshots
<p float="left">
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Poèetni%20zaslon.PNG" alt="Poèetni zaslon" width="250"/>
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Dnevnik%20ishrane.jpeg" alt="Dnevnik ishrane" width="250"/>
</p>
<p float="left">
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Nutritivne%20vrijednosti.jpeg" alt="Nutritivne vrijednost" width="250"/>
<img src="https://github.com/MarkoRezic/Calorie-Counter-Flutter/blob/master/UI%20Design/App%20Screenshots/Napredak.jpeg" alt="Napredak" width="250"/>
</p>