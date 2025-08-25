# Learn Work - Professional Learning App

A modern Flutter application designed for professional learning with a beautiful and professional UI.

## Features

### 🔐 User Authentication
- **User Registration**: Students can register with email, password, and phone number
- **User Login**: Secure login with email and password
- **Email & Phone Verification**: Required verification process for account security
- **Social Login**: Support for Google and Apple authentication (UI ready)
- **Forgot Password**: Password recovery functionality (UI ready)

### 🎨 Professional UI Design
- **Modern Material Design 3**: Following the latest Material Design guidelines
- **Responsive Layout**: Optimized for various screen sizes
- **Professional Color Scheme**: Carefully chosen colors for a business-like appearance
- **Smooth Animations**: Tab-based navigation between login and registration
- **Custom Form Fields**: Professional input fields with proper validation styling

### 📱 Screens

#### 1. Authentication Screen (`lib/screens/auth_screen.dart`)
- Tabbed interface for Login and Registration
- Professional form design with proper spacing and typography
- Social login options
- Terms and conditions acceptance

#### 2. Verification Screen (`lib/screens/verification_screen.dart`)
- 6-digit verification code input
- Auto-focus navigation between input fields
- Resend code functionality with countdown timer
- Support for both email and phone verification

#### 3. Home Screen (`lib/screens/home_screen.dart`)
- Welcome section with gradient background
- Quick action cards for common tasks
- Recent courses with progress tracking
- Professional dashboard layout

## Technical Details

### Dependencies
- **Flutter**: Latest stable version
- **Forui**: UI component library (v0.11.1)
- **Material Design 3**: Modern design system

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── auth_screen.dart     # Authentication UI
│   ├── verification_screen.dart  # Verification UI
│   └── home_screen.dart     # Home dashboard
```

### Design Principles
- **Accessibility**: Proper contrast ratios and readable fonts
- **Consistency**: Unified design language across all screens
- **Professional**: Business-appropriate color schemes and layouts
- **User Experience**: Intuitive navigation and clear visual hierarchy

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Test the UI**
   - Navigate between Login and Registration tabs
   - Try the registration flow to see verification screen
   - Test the login flow to see home screen
   - Experience the professional design and smooth transitions

## Future Enhancements

### Backend Integration
- [ ] Firebase Authentication
- [ ] Email/Phone verification services
- [ ] User profile management
- [ ] Course data integration

### Additional Features
- [ ] Biometric authentication
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Push notifications
- [ ] Offline mode

### UI Improvements
- [ ] Custom animations
- [ ] Loading states
- [ ] Error handling UI
- [ ] Success feedback

## Screenshots

The app features:
- Clean, professional authentication forms
- Modern verification code input
- Beautiful home dashboard with course progress
- Responsive design for all screen sizes

## Contributing

This is a UI demonstration project. The authentication logic and backend integration are placeholders for future development.

## License

This project is for educational and demonstration purposes.
