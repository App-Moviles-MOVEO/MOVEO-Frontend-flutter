// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WheelsPe';

  @override
  String get onboardingTitle1 => 'Monetize your vehicle';

  @override
  String get onboardingBody1 =>
      'List your car and earn income by renting it to verified users.';

  @override
  String get onboardingTitle2 => 'Verify your identity';

  @override
  String get onboardingBody2 =>
      'Upload your ID and operate with the trust of a verified community.';

  @override
  String get onboardingTitle3 => 'Get paid cashless';

  @override
  String get onboardingBody3 =>
      'Receive your payments directly in your WheelsPe digital wallet.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Welcome back, sign in to your provider account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Recover password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password';

  @override
  String get forgotPasswordSend => 'Send link';

  @override
  String get forgotPasswordSent =>
      'If an account with that email exists, a reset link has been sent';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordSubtitle =>
      'Enter the token you received and your new password';

  @override
  String get resetTokenLabel => 'Recovery token';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get resetPasswordSuccess =>
      'Password reset. Sign in with your new password';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get noAccountQuestion => 'Don\'t have an account? Sign up';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Join as a provider and start earning';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get acceptTerms => 'I accept the Terms and Conditions';

  @override
  String get registerButton => 'Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get invalidPhone => 'Phone must have 9 digits';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidPlate => 'Invalid plate format (e.g. ABC-123)';

  @override
  String get mustAcceptTerms => 'You must accept the terms and conditions';

  @override
  String get kycTitle => 'Identity verification';

  @override
  String get kycIntro => 'Verify your identity to start operating';

  @override
  String get kycUploadFront => 'Upload front of ID';

  @override
  String get kycUploadBack => 'Upload back of ID';

  @override
  String get kycSubmit => 'Submit documents';

  @override
  String get kycSkipForTesting => 'Skip verification (test mode)';

  @override
  String get kycReviewTime => 'Verification takes 24-48 hours';

  @override
  String get kycInReview => 'Your documents are under review';

  @override
  String get kycRejected => 'Verification rejected';

  @override
  String get kycRetry => 'Retry';

  @override
  String get kycVerified => 'Identity Verified';

  @override
  String get logout => 'Log out';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get availableBalance => 'Available balance';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get last7Days => 'Earnings last 7 days';

  @override
  String get pendingReservations => 'Pending reservations';

  @override
  String get todayRoutes => 'Active routes today';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get publishVehicle => 'List vehicle';

  @override
  String get publishRoute => 'Publish route';

  @override
  String get viewEarnings => 'View earnings';

  @override
  String get reportIncident => 'Report incident';

  @override
  String get confirm => 'Confirm';

  @override
  String get reject => 'Reject';

  @override
  String get cancel => 'Cancel';

  @override
  String get retryButton => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get seeAll => 'See all';

  @override
  String get navHome => 'Home';

  @override
  String get navFleet => 'My fleet';

  @override
  String get navRoutes => 'Routes';

  @override
  String get navProfile => 'Profile';

  @override
  String get fleetTitle => 'My vehicles';

  @override
  String get fleetEmpty => 'List your first vehicle';

  @override
  String get fleetEmptyBody =>
      'You don\'t have any listed vehicles yet. Start earning today.';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusRented => 'Rented';

  @override
  String get statusMaintenance => 'Maintenance';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String vehicleStats(int count, String amount) {
    return '$count reservations this month | $amount earned';
  }

  @override
  String get vehicleDetailTitle => 'Vehicle detail';

  @override
  String get pricePerDay => 'Price per day';

  @override
  String get category => 'Category';

  @override
  String get plate => 'Plate';

  @override
  String get year => 'Year';

  @override
  String get location => 'Location';

  @override
  String get description => 'Description';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get markAvailable => 'Mark available';

  @override
  String get markMaintenance => 'Send to maintenance';

  @override
  String get startDelivery => 'Start delivery';

  @override
  String get registerReturn => 'Register return';

  @override
  String get photoChecklist => 'Photo checklist';

  @override
  String get reservationsSection => 'Reservations';

  @override
  String get addVehicleTitle => 'List vehicle';

  @override
  String get stepBasicData => 'Basic data';

  @override
  String get stepPriceAvailability => 'Price and availability';

  @override
  String get stepPhotos => 'Photos';

  @override
  String get stepConfirmation => 'Confirmation';

  @override
  String get deliveryLocation => 'Delivery location';

  @override
  String get descriptionHint => 'Describe your vehicle (max 300 characters)';

  @override
  String get minPhotosRequired => 'Minimum 3 photos required';

  @override
  String photosCount(int current, int max) {
    return '$current/$max photos';
  }

  @override
  String get publishVehicleButton => 'List vehicle';

  @override
  String get vehiclePublished => 'Vehicle listed!';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get checklistTitlePre => 'Condition report — Pre rental';

  @override
  String get checklistTitlePost => 'Condition report — Post rental';

  @override
  String get checklistSubtitle => 'Take photos of every part of the vehicle';

  @override
  String checklistProgress(int done, int total) {
    return '$done/$total points registered';
  }

  @override
  String get checklistFinish => 'Finish report';

  @override
  String get checklistSaved => 'Report saved successfully';

  @override
  String get checkFront => 'Front';

  @override
  String get checkRightSide => 'Right side';

  @override
  String get checkLeftSide => 'Left side';

  @override
  String get checkRear => 'Rear';

  @override
  String get checkDriverInterior => 'Driver interior';

  @override
  String get checkPassengerInterior => 'Passenger interior';

  @override
  String get checkDashboard => 'Dashboard';

  @override
  String get checkTrunk => 'Trunk';

  @override
  String get checkTires => 'Tires';

  @override
  String get checkRoof => 'Roof';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get tabPending => 'Pending';

  @override
  String get tabActive => 'Active';

  @override
  String get tabHistory => 'History';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabInProgress => 'In progress';

  @override
  String get reservationDetailTitle => 'Reservation detail';

  @override
  String get renterInfo => 'Renter information';

  @override
  String get rentalInfo => 'Rental information';

  @override
  String get timeline => 'Timeline';

  @override
  String totalDays(int days) {
    return '$days days';
  }

  @override
  String get totalAmount => 'Total amount';

  @override
  String get deposit => 'Held deposit';

  @override
  String get confirmReservation => 'Confirm reservation';

  @override
  String get registerVehicleDelivery => 'Register vehicle delivery';

  @override
  String get registerVehicleReturn => 'Register return';

  @override
  String get viewReceipt => 'View receipt';

  @override
  String get noReservations => 'No reservations in this section';

  @override
  String get routesTitle => 'My routes';

  @override
  String get routesEmpty => 'You haven\'t published routes yet';

  @override
  String get routesEmptyBody => 'Share your route and cut your travel costs.';

  @override
  String seatsOccupied(int taken, int total) {
    return '$taken/$total taken';
  }

  @override
  String get pricePerSeat => 'Price per seat';

  @override
  String get addRouteTitle => 'Publish route';

  @override
  String get origin => 'Origin';

  @override
  String get destination => 'Destination';

  @override
  String get departureDate => 'Departure date';

  @override
  String get departureTime => 'Departure time';

  @override
  String get availableSeats => 'Available seats';

  @override
  String get upcOnly => 'UPC community only';

  @override
  String get womenOnly => 'Women only';

  @override
  String get additionalNotes => 'Additional notes (optional)';

  @override
  String get publishRouteButton => 'Publish route';

  @override
  String get routePublished => 'Route published!';

  @override
  String get routeDetailTitle => 'Route detail';

  @override
  String get passengers => 'Passengers';

  @override
  String get confirmedPassengers => 'Confirmed passengers';

  @override
  String get pendingRequests => 'Pending requests';

  @override
  String get accept => 'Accept';

  @override
  String get startRoute => 'Start route';

  @override
  String get finishRoute => 'Finish route';

  @override
  String get cancelRoute => 'Cancel route';

  @override
  String get routeEarningsSummary => 'Earnings summary';

  @override
  String get ratePassengers => 'Rate passengers';

  @override
  String get noPassengersYet => 'No passengers on this route yet';

  @override
  String get transactionsTitle => 'My earnings';

  @override
  String get monthTotal => 'Month total';

  @override
  String get transactionDetailTitle => 'Payment detail';

  @override
  String get platformFee => 'Platform fee';

  @override
  String get netReceived => 'Net received';

  @override
  String get reference => 'Reference';

  @override
  String get downloadReceipt => 'Download receipt';

  @override
  String get requestRefund => 'Request refund';

  @override
  String get refundProcessed => 'Refund processed';

  @override
  String get noTransactions => 'You have no payments yet';

  @override
  String get profileTitle => 'Profile';

  @override
  String get verifiedProvider => 'Verified Provider';

  @override
  String get badgesSection => 'My badges';

  @override
  String get badgeVerified => 'Verified';

  @override
  String get badgeVerifiedDesc => 'KYC completed';

  @override
  String get badgePunctual => 'Punctual';

  @override
  String get badgePunctualDesc => 'Over 90% on-time deliveries';

  @override
  String get badgeTopRenter => 'Top Renter';

  @override
  String get badgeTopRenterDesc => 'Over 10 completed rentals';

  @override
  String get badgeFiveStars => '5 Stars';

  @override
  String get badgeFiveStarsDesc => 'Average rating of 4.8 or higher';

  @override
  String get reputation => 'Reputation';

  @override
  String ratingsCount(int count) {
    return '$count ratings';
  }

  @override
  String get latestReviews => 'Latest reviews';

  @override
  String get noReviewsYet => 'You have no reviews yet';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalRentals => 'Completed rentals';

  @override
  String get totalRoutes => 'Routes as driver';

  @override
  String get totalEarnings => 'Accumulated earnings';

  @override
  String get wallet => 'Wallet';

  @override
  String get withdrawFunds => 'Withdraw funds';

  @override
  String get withdrawVia => 'Choose your withdrawal method';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get kycStatus => 'KYC status';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get incidentTitle => 'Report incident';

  @override
  String get incidentDescription => 'Incident description';

  @override
  String get incidentType => 'Incident type';

  @override
  String get incidentDamage => 'Vehicle damage';

  @override
  String get incidentAccident => 'Accident';

  @override
  String get incidentLateness => 'Lateness';

  @override
  String get incidentBehavior => 'Behavior';

  @override
  String get incidentOther => 'Other';

  @override
  String get photoEvidence => 'Photo evidence';

  @override
  String get relatedReservation => 'Related reservation/route';

  @override
  String get submitIncident => 'Submit report';

  @override
  String get incidentReported =>
      'Incident reported. The team will review it within 24h';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get connectionError => 'Connection error. Check your internet.';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get loading => 'Loading...';

  @override
  String get newReservationNotificationTitle => 'New pending reservation';

  @override
  String get newReservationNotificationBody =>
      'You have a new reservation request. Check it now.';

  @override
  String get yape => 'Yape';

  @override
  String get plin => 'Plin';

  @override
  String get card => 'Card';

  @override
  String get withdrawRequested => 'Withdrawal request sent';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get today => 'Today';

  @override
  String get rateUser => 'Rate user';

  @override
  String get comment => 'Comment';

  @override
  String get send => 'Send';

  @override
  String get ratingSent => 'Rating sent';
}
