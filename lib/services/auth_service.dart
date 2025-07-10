import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
	final FirebaseAuth _auth = FirebaseAuth.instance;
	final GoogleSignIn _googleSignIn = GoogleSignIn();

	Future<UserCredential> signInWithGoogle() async {
		try {
			// Ensure clean state before sign in
			final isSignedIn = await _googleSignIn.isSignedIn();
			if (isSignedIn) {
				await signOut();
				// Add delay to ensure cleanup is complete
				await Future.delayed(const Duration(milliseconds: 500));
			}

			// Trigger the authentication flow
			final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
			
			if (googleUser == null) {
				throw FirebaseAuthException(
					code: 'sign_in_canceled',
					message: 'Sign in was canceled by the user'
				);
			}

			// Obtain the auth details from the request
			final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

			// Create a new credential
			final OAuthCredential credential = GoogleAuthProvider.credential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken,
			);

			// Sign in to Firebase with the Google credential
			final UserCredential userCredential = await _auth.signInWithCredential(credential);
			
			if (userCredential.user == null) {
				throw FirebaseAuthException(
					code: 'sign_in_failed',
					message: 'Failed to sign in with Google'
				);
			}

			return userCredential;
		} catch (e) {
			print('Error signing in with Google: $e');
			rethrow;
		}
	}

	Future<void> signOut() async {
		try {
			// First disconnect Google Sign-In if connected
			final isSignedInWithGoogle = await _googleSignIn.isSignedIn();
			if (isSignedInWithGoogle) {
				try {
					await _googleSignIn.disconnect();
				} catch (e) {
					print('Error disconnecting Google Sign-In: $e');
				}
				try {
					await _googleSignIn.signOut();
				} catch (e) {
					print('Error signing out from Google: $e');
				}
			}

			// Then sign out from Firebase
			await _auth.signOut();
			
			// Clear any cached credentials
			await Future.delayed(const Duration(milliseconds: 800));
		} catch (e) {
			print('Error during sign out: $e');
			throw Exception('Failed to sign out properly: $e');
		}
	}
}