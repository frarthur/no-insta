# Installer NoInsta sur un iPhone (depuis Windows)

iOS ne se compile que sur macOS. On utilise donc GitHub Actions (gratuit, car le
repo est public) pour produire un `.ipa` **non signé**, qu'on signe ensuite avec
ton Apple ID directement sur le PC Windows via Sideloadly.

## 1. Compiler l'IPA

1. Onglet **Actions** du repo GitHub → workflow **iOS** → **Run workflow** (branche `dev` ou `main`).
2. À la fin du job, télécharger l'artefact **`noinsta-unsigned-ipa`** (contient `noinsta-unsigned.ipa`).
3. Durée : ~10–15 min la première fois (installation des pods CocoaPods).

Alternative locale : sur un Mac, `flutter build ios --release --no-codesign`, puis Xcode
pour signer directement sur l'iPhone branché en USB.

> L'IPA produit est **non signé** : il ne s'installe pas tel quel, il doit être
> re-signé avec ton Apple ID (étape 2).

## 2. Sideloader depuis Windows (Sideloadly)

Pré-requis, à installer depuis **apple.com** (⚠️ pas les versions du Microsoft Store,
elles ne fonctionnent pas) :

- iTunes pour Windows
- iCloud pour Windows

Puis :

1. Télécharger [Sideloadly](https://sideloadly.io/) et l'installer.
2. Brancher l'iPhone en USB, déverrouiller, puis **Faire confiance** à l'ordinateur.
3. Lancer Sideloadly : l'iPhone doit apparaître dans « iDevice ».
4. Glisser `noinsta-unsigned.ipa` dans la zone « IPA ».
5. Saisir ton **Apple ID** dans « Apple account » (un compte gratuit suffit).
6. Cliquer **Start**, puis entrer le mot de passe Apple ID (et le code 2FA) quand demandé.
7. Sur l'iPhone : **Réglages → Général → VPN et gestion de l'appareil → Développeur Apple → Faire confiance**.
8. iOS 16+ : le réglage **Réglages → Confidentialité et sécurité → Mode développeur** n'apparaît
   **qu'après** l'installation de l'app signée (c'est normal qu'il soit absent avant). L'activer,
   redémarrer l'iPhone, puis relancer l'app. Sur iOS 15, ce réglage n'existe pas et n'est pas
   nécessaire.

### Si l'installation échoue

- **`Login failed (-80046): This action cannot be completed at this time`** : depuis le
  **22 octobre 2026**, Apple refuse le jeton Xcode demandé par les outils qui se présentent
  comme un téléphone Android (Sideloadly, AltStore…). **Ce n'est pas ton compte ni ton IPA.**
  Sideloadly n'a pas encore de correctif. Utiliser **iloader** (gratuit, open source,
  Windows/Linux/macOS) qui passe par une anisette Mac :
  1. Installer iTunes (version apple.com).
  2. Télécharger `iloader-windows-x64.msi` sur https://github.com/nab138/iloader/releases/latest
     (v2.4.0 minimum).
  3. Brancher l'iPhone, lancer iloader, puis « Import IPA » → `noinsta-unsigned.ipa`.
  4. Se connecter avec l'Apple ID + 2FA (un « Mac » fantôme apparaît dans tes appareils
     Apple ID, c'est normal).
  5. Même suite qu'avec Sideloadly : confiance du certificat + mode développeur.
  ⚠️ Ne réessaie pas ton Apple ID en boucle sur Sideloadly : Apple peut verrouiller
  temporairement le compte.
- **« Unable to install » / erreur de bundle ID** : dans Sideloadly, ouvrir les options
  avancées et changer le *Bundle ID* (par ex. `com.tonpseudo.noinsta`).
- **L'app se ferme au démarrage** : vérifier le Mode développeur (étape 8) puis
  re-signer l'app.
- **iTunes/iCloud non détectés** : désinstaller les versions Microsoft Store, réinstaller
  celles d'apple.com, rebooter.

## 3. Limites d'un Apple ID gratuit

| Limite | Valeur |
| --- | --- |
| Durée de la signature | **7 jours** (ensuite « Impossible de vérifier l'app ») |
| Nombre d'apps sideloadées | 3 par appareil |
| Re-signature | À refaire chaque semaine (Sideloadly ou AltStore en Wi-Fi) |

Pour éviter la re-signature hebdomadaire : compte **Apple Developer Program**
(99 $/an, signature 1 an + TestFlight), ou passer par AltStore qui rafraîchit
automatiquement en Wi-Fi tant qu'AltServer tourne sur le PC.

## 4. Après l'installation

- Se connecter à Instagram dans l'app (login + 2FA).
- Autoriser micro et photothèque au premier usage (voix / photos).
- L'app charge `https://www.instagram.com/direct/inbox/` et masque le fil + les reels.

## 5. Publication App Store

Une app qui encapsule Instagram est très probablement refusée (règles Apple 4.1 et
5.2.1 sur le contenu d'un tiers). Le sideload reste la voie réaliste pour un usage
personnel.
