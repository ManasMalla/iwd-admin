import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(
          clientId:
              "589766530196-tgsd5c3sf4a6vefghm4lhmei8q8c7koc.apps.googleusercontent.com",
        ).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  final isLoading = ValueNotifier<bool>(false);
  getUserRole(User? user) async {
    final response =
        (await FirebaseFirestore.instance
                .collection("registrations")
                .doc(user?.uid)
                .get())
            .data();
    return response?["role"];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, value, child) {
        return FirebaseAuth.instance.currentUser != null
            ? FutureBuilder(
              future: getUserRole(FirebaseAuth.instance.currentUser),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DashboardPage(userRole: snapshot.data);
                }
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            )
            : Stack(
              children: [
                Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () async {
                        isLoading.value = true;
                        final user = await signInWithGoogle();
                        if (user.user == null) {
                          isLoading.value = false;
                          return;
                        }
                        print(user.user?.uid);
                        final userRole = await getUserRole(user.user);
                        if (userRole != "volunteer") {
                          isLoading.value = false;
                          await FirebaseAuth.instance.signOut();
                          return;
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder:
                                (context) => DashboardPage(userRole: userRole),
                          ),
                        );
                      },
                      child:
                          value
                              ? CircularProgressIndicator()
                              : Text("Sign in With Google"),
                    ),
                  ),
                ),
              ],
            );
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  final userRole;
  const DashboardPage({super.key, required this.userRole})
    : assert(userRole == "volunteer" || userRole == "admin");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("IWD 2025"),
            SizedBox(width: 8),
            Chip(
              backgroundColor:
                  userRole == "volunteer"
                      ? Color(0xFF0F7C67)
                      : Color(0xFF165185),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48),
              ),
              label: Text(
                userRole.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ClipOval(
            child: CircleAvatar(
              child: Image.network(
                FirebaseAuth.instance.currentUser?.photoURL ??
                    "https://github.com/ManasMalla.png",
              ),
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FilledButton(
              //   onPressed: () {
              //     fetchModalBottomSheetForCategory(
              //       context,
              //       "Dummy",
              //       "dummy",
              //       "Dummy Already Provided",
              //       "Manas",
              //       "Malla",
              //       "Email: manasmalla.dev@gmail.com\nGender: She/Her\nTshirt Size: M\nUniversity: Gandhi Insitiute of Engineering and Technology",
              //       () {},
              //     );
              //   },
              //   child: Text("Test Button"),
              // ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "Check-in",
                    "check-in",
                    "Already Checked-in",
                    "Are you sure you want to confirm the check-in for the user?",
                  );
                },
                text: "Check-in",
              ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "T-Shirt",
                    "tshirt_provided",
                    "Already given tshirt",
                    "Are you sure you want to confirm the tshirt provided?",
                  );
                },
                text: "T-Shirt",
              ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "Lunch",
                    "lunch",
                    "Lunch Already Provided",
                    "Are you sure you want to confirm the lunch for the user?",
                  );
                },
                text: "Lunch",
              ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "Dinner",
                    "dinner",
                    "Dinner Already Provided",
                    "Are you sure you want to confirm the dinner for the user?",
                  );
                },
                text: "Dinner",
              ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "Breakfast",
                    "breakfast",
                    "Breakfast Already Provided",
                    "Are you sure you want to confirm the breakfast for the user?",
                  );
                },
                text: "Breakfast",
              ),
              DashboardCard(
                onPressed: () {
                  updateStatusInFirebase(
                    context,
                    "Swags",
                    "swags",
                    "Swags Already Provided",
                    "Are you sure you want to confirm the swags for the user?",
                  );
                },
                text: "Swags",
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateStatusInFirebase(
    BuildContext context,
    String title,
    String id,
    String existError,
    String description,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MyHomePage(
              title: title,
              onScan: (p0) async {
                final doc =
                    (await FirebaseFirestore.instance
                            .collection("registrations")
                            .doc(p0)
                            .get())
                        .data();
                if (doc?[id] ?? false) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(existError)));
                  return;
                }
                fetchModalBottomSheetForCategory(
                  context,
                  title,
                  id,
                  existError,
                  doc?["firstName"],
                  doc?["lastName"],
                  description +
                      (id == "check-in"
                          ? "\n\nEmail: ${doc?['email']}\nGender: ${doc?['gender']}\nTshirt Size: ${doc?['tshirtSize']}\nUniversity: ${(doc?["university"] == "Other") ? (doc?["otherUniversity"]) : doc?["university"]}"
                          : ""),
                  () async {
                    await FirebaseFirestore.instance
                        .collection("registrations")
                        .doc(p0)
                        .update({id: true});
                  },
                );
              },
            ),
      ),
    );
  }

  void fetchModalBottomSheetForCategory(
    BuildContext context,
    String title,
    String id,
    String existError,
    String firstName,
    String lastName,
    String description,
    Function onPressed,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            final isUpdating = ValueNotifier<bool>(false);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$title for $firstName $lastName",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(description),
                  SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: isUpdating,
                    builder: (context, valueIsUpdating, child) {
                      return FilledButton(
                        onPressed: () async {
                          onPressed();
                          isUpdating.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$title Successfully")),
                          );
                          Navigator.pop(context);
                        },
                        child:
                            valueIsUpdating
                                ? CircularProgressIndicator()
                                : Text(title),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String text;
  final Function() onPressed;
  const DashboardCard({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.category_outlined),
                  SizedBox(height: 8),
                  Text(text),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.onScan});

  final String title;
  final Function(String) onScan;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MobileScannerWidget extends StatefulWidget {
  const MobileScannerWidget({super.key, required this.onScan});
  final Function(String) onScan;

  @override
  State<MobileScannerWidget> createState() => _MobileScannerWidgetState();
}

class _MobileScannerWidgetState extends State<MobileScannerWidget> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _scannerController,
      onDetect: (barcodes) async {
        final List<Barcode> barCodesCaptured = barcodes.barcodes;
        String? data;
        for (final barCode in barCodesCaptured) {
          if (barCode.rawValue != null) {
            data = barCode.rawValue;
          }
        }
        if (data != null) {
          await _scannerController.stop();
          await widget.onScan(data);
        }
        print("QR Code Found!");
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: MobileScannerWidget(
        onScan: (userId) {
          widget.onScan(userId);
        },
      ),
    );
  }
}
