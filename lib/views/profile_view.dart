import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/user_model.dart';
import '../models/auth_models.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';
import '../services/auth_service.dart';
import 'login_view.dart';
import 'account_activation_view.dart';



class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final StorageService _storageService = StorageService();
  final LoggerService _logger = LoggerService();
  final ImagePicker _imagePicker = ImagePicker();
  final AuthService _authService = AuthService();
  
  // Genişletilebilir panellerin durumlarını takip etmek için
  bool _isAccountSectionExpanded = false;
  bool _isHelpSectionExpanded = false;
  bool _isAppInfoSectionExpanded = false;
  bool _isLoadingImage = false;
  
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında profil verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile();
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  Future<void> _logout() async {
    await _storageService.clearUserData();
    _logger.i('Kullanıcı çıkış yaptı');
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        platformPageRoute(
          context: context,
          builder: (context) => const LoginView(),
        ),
        (route) => false,
      );
    }
  }

  void _launchWebsite() async {
    const websiteUrl = 'https://todobus.tr';
    final Uri uri = Uri.parse(websiteUrl);
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _logger.e('Web sitesi açılamadı: $websiteUrl');
        if (mounted) {
          showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: const Text('Hata'),
              content: const Text('Web sitesi açılamadı. Lütfen daha sonra tekrar deneyin.'),
              actions: <Widget>[
                PlatformDialogAction(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } else {
        _logger.i('Todobus web sitesi açıldı: $websiteUrl');
      }
    } catch (e) {
      _logger.e('Web sitesi açılırken hata oluştu: $e');
      if (mounted) {
        showPlatformDialog(
          context: context,
          builder: (context) => PlatformAlertDialog(
            title: const Text('Hata'),
            content: Text('Web sitesi açılırken bir hata oluştu: ${e.toString()}'),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('Tamam'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _launchUrl(String url, String pageName) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _logger.e('$pageName açılamadı: $url');
        if (mounted) {
          showPlatformDialog(
            context: context,
            builder: (context) => PlatformAlertDialog(
              title: const Text('Hata'),
              content: Text('$pageName açılamadı. Lütfen daha sonra tekrar deneyin.'),
              actions: <Widget>[
                PlatformDialogAction(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      } else {
        _logger.i('$pageName açıldı: $url');
      }
    } catch (e) {
      _logger.e('$pageName açılırken hata oluştu: $e');
      if (mounted) {
        showPlatformDialog(
          context: context,
          builder: (context) => PlatformAlertDialog(
            title: const Text('Hata'),
            content: Text('$pageName açılırken bir hata oluştu: ${e.toString()}'),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('Tamam'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openMembershipAgreement() {
    _launchUrl('https://www.todobus.tr/uyelik-sozlesmesi', 'Üyelik Sözleşmesi');
  }

  void _openPrivacyPolicy() {
    _launchUrl('https://www.todobus.tr/gizlilik-politikasi', 'Gizlilik Politikası');
  }

  void _openKVKKTerms() {
    _launchUrl('https://www.todobus.tr/kvkk-aydinlatma-metni', 'KVKK Aydınlatma Metni');
  }
  
  void _openFAQ() {
    _launchUrl('https://www.todobus.tr#faq', 'SSS');
  }
  
  void _openContact() {
    _launchUrl('https://www.todobus.tr/iletisim', 'İletişim');
  }
  
  void _openTermsOfUse() {
    _launchUrl('https://www.todobus.tr/site-kullanim-sartlari', 'Kullanım Şartları');
  }

  // Profil düzenleme ekranını aç
  void _navigateToEditProfile() {
    final user = context.read<ProfileViewModel>().user;
    if (user != null) {
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (context) => EditProfileView(user: user),
        ),
      );
    }
  }

  // Şifre değiştirme ekranını aç
  void _navigateToChangePasswordView() {
    Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (context) => const ChangePasswordView(),
      ),
    );
  }

  // Hesap aktivasyon sayfasına yönlendir
  Future<void> _navigateToActivation() async {
    final result = await Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (context) => const AccountActivationView(),
      ),
    );
    
    // Eğer aktivasyon başarılı olduysa profil bilgilerini yenile
    if (result == true && mounted) {
      context.read<ProfileViewModel>().loadUserProfile();
    }
  }

  // Hesap silme işlemini başlat - Profesyonel ve vazgeçirir yaklaşım
  Future<void> _initiateDeleteAccount() async {
    // İlk doğrulama: Ciddi uyarı
    final seriousWarning = await _showSeriousWarningDialog();
    if (!seriousWarning) return;

    // Şifre doğrulaması
    final passwordConfirm = await _showPasswordConfirmation();
    if (!passwordConfirm) return;

    // Son onay ve bekleme süresi
    final finalConfirm = await _showFinalConfirmationWithDelay();
    if (!finalConfirm) return;

    // Hesap silme işlemini gerçekleştir
    await _performDeleteAccount();
  }

  // Ciddi uyarı diyalogu
  Future<bool> _showSeriousWarningDialog() async {
    final result = await showPlatformDialog<bool>(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(
          'Hesap Silme İşlemi',
          style: TextStyle(
            color: platformThemeData(
              context,
              material: (data) => Colors.red.shade800,
              cupertino: (data) => CupertinoColors.systemRed,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'UYARI: Bu işlem kalıcıdır ve geri alınamaz.\n\n'
          'Hesabınız silindiğinde:\n'
          '• Tüm verileriniz kalıcı olarak silinecektir\n'
          '• Profil bilgileriniz kurtarılamayacaktır\n'
          '• Aynı e-posta ile yeniden kayıt olsanız bile geçmiş verileriniz geri gelmeyecektir\n'
          '• İşlem tamamlandıktan sonra herhangi bir geri alma imkanı bulunmamaktadır\n\n'
          'Bu riskleri kabul edip devam etmek istediğinizden emin misiniz?'
        ),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('İptal Et'),
            onPressed: () => Navigator.pop(context, false),
          ),
          PlatformDialogAction(
            child: Text(
              'Riskleri Anlıyorum, Devam Et',
              style: TextStyle(
                color: platformThemeData(
                  context,
                  material: (data) => Colors.red.shade800,
                  cupertino: (data) => CupertinoColors.systemRed,
                ),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Şifre doğrulama diyalogu
  Future<bool> _showPasswordConfirmation() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    final result = await showPlatformDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => PlatformAlertDialog(
          title: const Text('Güvenlik Doğrulaması'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kimlik doğrulaması için mevcut şifrenizi giriniz:'),
              const SizedBox(height: 16),
              isCupertino(context)
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: passwordController,
                              placeholder: 'Mevcut şifreniz',
                              obscureText: obscurePassword,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            child: Icon(
                              obscurePassword 
                                  ? CupertinoIcons.eye 
                                  : CupertinoIcons.eye_slash,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'Mevcut şifreniz',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: obscurePassword,
                    ),
            ],
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: const Text('İptal'),
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            PlatformDialogAction(
              child: const Text('Doğrula'),
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  _showErrorMessage('Şifre alanı boş olamaz');
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
            ),
          ],
        ),
      ),
    );
    
    passwordController.dispose();
    return result ?? false;
  }

  // Bekleme süresi ile son onay
  Future<bool> _showFinalConfirmationWithDelay() async {
    bool canProceed = false;
    
    final result = await showPlatformDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // 5 saniye sonra buton aktif olsun
          if (!canProceed) {
            Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  canProceed = true;
                });
              }
            });
          }
          
          return PlatformAlertDialog(
            title: const Text('Son Onay'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bu işlemi gerçekleştirmek için 5 saniye bekletiyoruz. Bu süreyi kararınızı bir kez daha düşünmek için kullanın.\n\n'
                  'Hesabınızı sildiğinizde tüm verileriniz kalıcı olarak kaybolacaktır.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                if (!canProceed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: PlatformCircularProgressIndicator(),
                      ),
                      const SizedBox(width: 12),
                      const Text('Lütfen bekleyiniz...'),
                    ],
                  ),
              ],
            ),
            actions: <Widget>[
              PlatformDialogAction(
                child: const Text('Vazgeç'),
                onPressed: () => Navigator.pop(dialogContext, false),
              ),
              PlatformDialogAction(
                child: Text(
                  'Hesabımı Sil',
                  style: TextStyle(
                    color: canProceed
                        ? platformThemeData(
                            context,
                            material: (data) => Colors.red.shade800,
                            cupertino: (data) => CupertinoColors.systemRed,
                          )
                        : platformThemeData(
                            context,
                            material: (data) => Colors.grey,
                            cupertino: (data) => CupertinoColors.systemGrey,
                          ),
                  ),
                ),
                onPressed: canProceed
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
              ),
            ],
          );
        },
      ),
    );
    
    return result ?? false;
  }

  // Hesap silme işlemini gerçekleştir
  Future<void> _performDeleteAccount() async {
    try {
      // Loading dialog göster
      showPlatformDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PlatformAlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformCircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text('İşlem gerçekleştiriliyor...'),
            ],
          ),
        ),
      );

      final user = context.read<ProfileViewModel>().user;
      if (user?.userToken == null) {
        Navigator.pop(context);
        _showErrorMessage('Kullanıcı oturum bilgisi bulunamadı');
        return;
      }

      final response = await _authService.deleteUser(user!.userToken);
      
      Navigator.pop(context);

      if (response.success) {
        await _storageService.clearUserData();
        _logger.i('Kullanıcı hesabı başarıyla silindi');
        
        if (mounted) {
          showPlatformDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PlatformAlertDialog(
              title: const Text('İşlem Tamamlandı'),
              content: const Text(
                'Hesabınız başarıyla silindi. Uygulamadan çıkış yapılıyor.',
              ),
              actions: <Widget>[
                PlatformDialogAction(
                  child: const Text('Tamam'),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      platformPageRoute(
                        context: context,
                        builder: (context) => const LoginView(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        }
      } else {
        _showErrorMessage(
          response.userFriendlyMessage ?? 
          response.message ?? 
          'Hesap silme işlemi başarısız oldu'
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _logger.e('Hesap silme hatası: $e');
      _showErrorMessage('İşlem sırasında bir hata oluştu: ${e.toString()}');
    }
  }

  // Hata mesajı göster
  void _showErrorMessage(String message) {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        return PlatformScaffold(
          appBar: PlatformAppBar(
            title: const Text('Profil'),
            material: (_, __) => MaterialAppBarData(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: viewModel.user != null ? _navigateToEditProfile : null,
                  tooltip: 'Profili Düzenle',
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _logout,
                  tooltip: 'Çıkış Yap',
                ),
              ],
            ),
            cupertino: (_, __) => CupertinoNavigationBarData(
              transitionBetweenRoutes: false,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.pencil),
                    onPressed: viewModel.user != null ? _navigateToEditProfile : null,
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.square_arrow_right),
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
          ),
          body: _buildBody(context, viewModel),
        );
      },
    );
  }
  
  Widget _buildBody(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.status == ProfileStatus.loading) {
      return Center(
        child: PlatformCircularProgressIndicator(),
      );
    } else if (viewModel.status == ProfileStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: platformThemeData(
                  context,
                  material: (data) => Colors.red,
                  cupertino: (data) => CupertinoColors.systemRed,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(viewModel.errorMessage),
            const SizedBox(height: 16),
            PlatformElevatedButton(
              onPressed: () => viewModel.loadUserProfile(),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }
    
    final user = viewModel.user;
    
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          
          // Hesap aktivasyon uyarısı ve doğrulama kodu girişi için modal dialog kullanılacak
          // Artık buraya bir bölüm eklemiyoruz, bunun yerine profil başlığında göstereceğiz
          
          // Hesap Bilgileri bölümü - genişletilebilir panel
          _buildExpandableSection(
            context,
            title: 'Hesap Bilgileri',
            isExpanded: _isAccountSectionExpanded,
            onTap: () {
              setState(() {
                _isAccountSectionExpanded = !_isAccountSectionExpanded;
              });
            },
            children: [
              _buildListItem(context, 'Ad Soyad', user?.userFullname ?? ""),
              _buildListItem(context, 'E-posta', user?.userEmail ?? ""),
              _buildListItem(context, 'Doğum Tarihi', user?.userBirthday ?? ""),
              _buildListItem(context, 'Cinsiyet', _getGenderText(user?.userGender ?? "")),
              _buildListItem(
                context, 
                'Şifre', 
                '********', 
                onTap: () => _navigateToChangePasswordView(),
                isLink: false
              ),
              // Hesap silme seçeneği - kırmızı renkte
              Container(
                margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
                child: _buildDeleteAccountItem(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Yardım bölümü - genişletilebilir panel
          _buildExpandableSection(
            context,
            title: 'Yardım',
            isExpanded: _isHelpSectionExpanded,
            onTap: () {
              setState(() {
                _isHelpSectionExpanded = !_isHelpSectionExpanded;
              });
            },
            children: [
              _buildListItem(
                context, 
                'SSS', 
                'İncele',
                onTap: _openFAQ,
                isLink: true
              ),
              _buildListItem(
                context, 
                'İletişim', 
                'İncele',
                onTap: _openContact,
                isLink: true
              ),
              _buildListItem(
                context, 
                'Üyelik Sözleşmesi', 
                'İncele',
                onTap: _openMembershipAgreement,
                isLink: true
              ),
              _buildListItem(
                context, 
                'Gizlilik Politikası', 
                'İncele',
                onTap: _openPrivacyPolicy,
                isLink: true
              ),
              _buildListItem(
                context, 
                'KVKK Aydınlatma', 
                'İncele',
                onTap: _openKVKKTerms,
                isLink: true
              ),
              _buildListItem(
                context, 
                'Kullanım Şartları', 
                'İncele',
                onTap: _openTermsOfUse,
                isLink: true
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Uygulama Bilgileri bölümü - genişletilebilir panel
          _buildExpandableSection(
            context,
            title: 'Uygulama Bilgileri',
            isExpanded: _isAppInfoSectionExpanded,
            onTap: () {
              setState(() {
                _isAppInfoSectionExpanded = !_isAppInfoSectionExpanded;
              });
            },
            children: [
              _buildListItem(context, 'Uygulama Adı', viewModel.appName),
              _buildListItem(context, 'Versiyon', '${viewModel.appVersion} (${viewModel.buildNumber})'),
              _buildListItem(context, 'Web Sitesi', 'todobus.tr', 
                onTap: _launchWebsite,
                isLink: true
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Web sitesi linki
          GestureDetector(
            onTap: _launchWebsite,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'todobus.tr',
                  style: TextStyle(
                    color: platformThemeData(
                      context,
                      material: (data) => Colors.blue,
                      cupertino: (data) => CupertinoColors.activeBlue,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Powered by Rivorya Yazılım
          Center(
            child: Text(
              'Powered by Rivorya Yazılım',
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                cupertino: (data) => data.textTheme.textStyle.copyWith(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          PlatformElevatedButton(
            onPressed: _logout,
            child: Text(
              'Çıkış Yap',
              style: TextStyle(
                color: isCupertino(context) ? CupertinoColors.white : null,
              ),
            ),
            material: (_, __) => MaterialElevatedButtonData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            cupertino: (_, __) => CupertinoElevatedButtonData(
              color: CupertinoColors.destructiveRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Cinsiyet değerini metne çevir
  String _getGenderText(String genderValue) {
    switch(genderValue) {
      case "Erkek": return "Erkek";
      case "Kadın": return "Kadın";
      default: return "Belirtilmemiş";
    }
  }
  
  Widget _buildProfileHeader(BuildContext context, User? user) {
    String profileImageUrl = user?.profilePhoto ?? '';
    bool hasProfileImage = profileImageUrl.isNotEmpty && profileImageUrl != 'null';
    bool isNotActivated = user != null && user.userStatus == 'not_activated';
    
    return Column(
      children: [
        // Profil fotoğrafı ve kullanıcı adı
        Center(
          child: Column(
            children: [
              // Profil fotoğrafı
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: hasProfileImage 
                          ? null 
                          : platformThemeData(
                              context,
                              material: (data) => Colors.blue.shade100,
                              cupertino: (data) => CupertinoColors.activeBlue.withOpacity(0.2),
                            ),
                      shape: BoxShape.circle,
                      image: hasProfileImage
                          ? DecorationImage(
                              image: NetworkImage(profileImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !hasProfileImage 
                        ? Center(
                            child: Icon(
                              context.platformIcons.person,
                              size: 50,
                              color: platformThemeData(
                                context,
                                material: (data) => Colors.blue,
                                cupertino: (data) => CupertinoColors.activeBlue,
                              ),
                            ),
                          )
                        : null,
                  ),
                  
                  // Aktivasyon durumu rozeti
                  if (isNotActivated)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => _navigateToActivation(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: platformThemeData(
                              context,
                              material: (data) => Colors.orange,
                              cupertino: (data) => CupertinoColors.systemOrange,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: platformThemeData(
                                context,
                                material: (data) => Colors.white,
                                cupertino: (data) => CupertinoColors.white,
                              ),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isCupertino(context) 
                                ? CupertinoIcons.exclamationmark 
                                : Icons.priority_high,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Kullanıcı adı
              const SizedBox(height: 12),
              Text(
                user?.userFullname ?? 'Yükleniyor...',
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.headlineSmall,
                  cupertino: (data) => data.textTheme.navLargeTitleTextStyle.copyWith(fontSize: 24),
                ),
              ),
              
              // Aktivasyon durumu mesajı
              if (isNotActivated)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                    onTap: () => _navigateToActivation(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: platformThemeData(
                          context,
                          material: (data) => Colors.orange.shade100,
                          cupertino: (data) => CupertinoColors.systemOrange.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCupertino(context) 
                                ? CupertinoIcons.exclamationmark_triangle 
                                : Icons.warning_amber_rounded,
                            color: platformThemeData(
                              context,
                              material: (data) => Colors.orange.shade800,
                              cupertino: (data) => CupertinoColors.systemOrange,
                            ),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hesabı Doğrula',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: platformThemeData(
                                context,
                                material: (data) => Colors.orange.shade800,
                                cupertino: (data) => CupertinoColors.systemOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  
  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: platformThemeData(
          context,
          material: (data) => data.cardColor,
          cupertino: (data) => CupertinoColors.systemBackground,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCupertino(context)
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Başlık ve genişletme iconu
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: platformThemeData(
                      context,
                      material: (data) => data.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      cupertino: (data) => data.textTheme.navTitleTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          // Genişletildiğinde gösterilecek içerik
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
  
  Widget _buildListItem(
    BuildContext context, 
    String title, 
    String value, {
    VoidCallback? onTap, 
    bool isLink = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8, right: 16, left: 16),
        decoration: BoxDecoration(
          color: platformThemeData(
            context,
            material: (data) => data.cardColor.withOpacity(0.7),
            cupertino: (data) => CupertinoColors.systemBackground,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: platformThemeData(
              context,
              material: (data) => Colors.grey.shade200,
              cupertino: (data) => CupertinoColors.systemGrey5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.titleSmall,
                  cupertino: (data) => data.textTheme.textStyle.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
                  color: isLink
                      ? platformThemeData(
                          context,
                          material: (data) => Colors.blue,
                          cupertino: (data) => CupertinoColors.activeBlue,
                        )
                      : platformThemeData(
                          context,
                          material: (data) => data.textTheme.bodyMedium?.color,
                          cupertino: (data) => CupertinoColors.secondaryLabel,
                        ),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (onTap != null && !isLink)
              Icon(
                context.platformIcons.rightChevron,
                size: 16,
                color: platformThemeData(
                  context,
                  material: (data) => Colors.grey,
                  cupertino: (data) => CupertinoColors.systemGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hesap silme öğesi - profesyonel görünüm
  Widget _buildDeleteAccountItem(BuildContext context) {
    return GestureDetector(
      onTap: _showAccountManagementOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: platformThemeData(
            context,
            material: (data) => Colors.grey.shade50,
            cupertino: (data) => CupertinoColors.systemGrey6,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: platformThemeData(
              context,
              material: (data) => Colors.grey.shade300,
              cupertino: (data) => CupertinoColors.systemGrey4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCupertino(context) ? CupertinoIcons.settings : Icons.settings,
              color: platformThemeData(
                context,
                material: (data) => Colors.grey.shade600,
                cupertino: (data) => CupertinoColors.systemGrey,
              ),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hesap Yönetimi',
                style: TextStyle(
                  color: platformThemeData(
                    context,
                    material: (data) => Colors.grey.shade700,
                    cupertino: (data) => CupertinoColors.label,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              context.platformIcons.rightChevron,
              size: 16,
              color: platformThemeData(
                context,
                material: (data) => Colors.grey.shade500,
                cupertino: (data) => CupertinoColors.systemGrey2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hesap yönetimi seçenekleri
  Future<void> _showAccountManagementOptions() async {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Hesap Yönetimi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesabınızla ilgili işlemler:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Hesap silme seçeneği
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _initiateDeleteAccount();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: platformThemeData(
                      context,
                      material: (data) => Colors.red.shade50,
                      cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: platformThemeData(
                        context,
                        material: (data) => Colors.red.shade200,
                        cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCupertino(context) ? CupertinoIcons.trash : Icons.delete_outline,
                        color: platformThemeData(
                          context,
                          material: (data) => Colors.red.shade600,
                          cupertino: (data) => CupertinoColors.systemRed,
                        ),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesabı Kalıcı Olarak Sil',
                              style: TextStyle(
                                color: platformThemeData(
                                  context,
                                  material: (data) => Colors.red.shade700,
                                  cupertino: (data) => CupertinoColors.systemRed,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bu işlem geri alınamaz ve tüm verileriniz silinir',
                              style: TextStyle(
                                color: platformThemeData(
                                  context,
                                  material: (data) => Colors.red.shade500,
                                  cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.7),
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        context.platformIcons.rightChevron,
                        size: 14,
                        color: platformThemeData(
                          context,
                          material: (data) => Colors.red.shade400,
                          cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Profil Düzenleme Ekranı
class EditProfileView extends StatefulWidget {
  final User user;
  
  const EditProfileView({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final LoggerService _logger = LoggerService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;
  
  String _selectedGender = "0"; // String tipine değiştirildi
  bool _isLoading = false;
  bool _isLoadingImage = false;
  String _errorMessage = '';
  String? _profileImageBase64;
  
  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.userFullname);
    _emailController = TextEditingController(text: widget.user.userEmail);
    _birthdayController = TextEditingController(text: widget.user.userBirthday);
    
    // Cinsiyet değerini String olarak ayarla ve API'den gelen string değeri sayıya çevir
    String userGender = widget.user.userGender;
    if (userGender == "Erkek") {
      _selectedGender = "1";
    } else if (userGender == "Kadın") {
      _selectedGender = "2";
    } else if (userGender == "1" || userGender == "2") {
      _selectedGender = userGender;
    } else {
      _selectedGender = "0"; // Belirtilmemiş
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }
  
  // Profil fotoğrafı seçme
  Future<void> _pickProfileImage() async {
    // Eğer zaten yükleme işlemi devam ediyorsa, yeni bir işlem başlatma
    if (_isLoadingImage) return;
    
    try {
      setState(() {
        _isLoadingImage = true;
      });
      
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedImage == null) {
        setState(() {
          _isLoadingImage = false;
        });
        return;
      }
      
      // Android'de image_cropper sorunları nedeniyle basit bir yeniden boyutlandırma kullan
      if (Platform.isAndroid) {
        await _processImageForAndroid(File(pickedImage.path));
      } else {
        // iOS'ta normal kırpma işlemi
        final croppedFile = await _cropImage(File(pickedImage.path));
        if (croppedFile != null) {
          await _convertImageToBase64(croppedFile);
        }
      }
      
    } catch (e) {
      _logger.e('Profil fotoğrafı seçilirken hata: $e');
      if (mounted) {
        _showErrorMessage('Görsel seçilirken bir hata oluştu. Lütfen tekrar deneyin.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }
  
  // Android için basit resim işleme
  Future<void> _processImageForAndroid(File imageFile) async {
    try {
      // Sadece base64'e çevir, kırpma işlemi yapmadan
      await _convertImageToBase64(imageFile);
    } catch (e) {
      _logger.e('Android resim işleme hatası: $e');
      throw e;
    }
  }
  
  // Resmi base64'e çevir
  Future<void> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      if (mounted) {
        setState(() {
          _profileImageBase64 = base64Image;
        });
      }
    } catch (e) {
      _logger.e('Base64 dönüştürme hatası: $e');
      throw e;
    }
  }
  
  // Resmi kırpma (sadece iOS için)
  Future<File?> _cropImage(File imageFile) async {
    try {
      // iOS için image cropper kullan
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 80,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          IOSUiSettings(
            title: 'Profil Fotoğrafını Düzenle',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      _logger.e('Resim kırpılırken hata: $e');
      return imageFile; // Hata durumunda orijinal dosyayı döndür
    }
  }
  
  // Hata mesajı göster
  void _showErrorMessage(String message) {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  // Profil güncelleme işlemi
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Gender değerini güvenli bir şekilde dönüştür
      int userGender;
      try {
        userGender = int.parse(_selectedGender);
      } catch (e) {
        _logger.e('Gender dönüştürme hatası: $_selectedGender', e);
        userGender = 0; // Varsayılan değer
      }
      
      // Tarih formatını kontrol et
      String birthday = _birthdayController.text.trim();
      if (birthday.isNotEmpty && !RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(birthday)) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Doğum tarihi GG.AA.YYYY formatında olmalıdır';
        });
        return;
      }
      
      // Profil güncelleme işlemini çağır
      await context.read<ProfileViewModel>().updateUserProfile(
        userFullname: _fullNameController.text.trim(),
        userEmail: _emailController.text.trim(),
        userBirthday: birthday,
        userGender: userGender,
        profilePhoto: _profileImageBase64 ?? widget.user.profilePhoto,
      );
      
      if (mounted) {
        final viewModel = context.read<ProfileViewModel>();
        if (viewModel.status == ProfileStatus.updateSuccess) {
          // Başarı mesajını platform uyumlu dialog ile göster
          showPlatformDialog(
            context: context,
            builder: (dialogContext) => PlatformAlertDialog(
              title: const Text('Başarılı'),
              content: const Text('Profil başarıyla güncellendi'),
              actions: <Widget>[
                PlatformDialogAction(
                  child: const Text('Tamam'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop(); // Önceki sayfaya dön
                  },
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _errorMessage = viewModel.errorMessage.isNotEmpty 
                ? viewModel.errorMessage 
                : 'Profil güncellenirken bir hata oluştu. Lütfen tekrar deneyiniz.';
          });
        }
      }
    } catch (e) {
      _logger.e('Profil güncellenirken hata: $e');
      setState(() {
        _errorMessage = 'Profil güncellenirken bir hata oluştu: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Profili Düzenle'),
        material: (_, __) => MaterialAppBarData(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _updateProfile,
              tooltip: 'Kaydet',
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          transitionBetweenRoutes: false,
          trailing: _isLoading 
          ? const CupertinoActivityIndicator()
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Kaydet'),
              onPressed: _updateProfile,
            ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profil fotoğrafı seçme alanı
              _buildProfilePhotoSelector(),
              
              const SizedBox(height: 24),
              
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: platformThemeData(
                      context,
                      material: (data) => Colors.red.shade100,
                      cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: platformThemeData(
                        context,
                        material: (data) => Colors.red,
                        cupertino: (data) => CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                ),
              
              _buildTextFormField(
                context: context,
                controller: _fullNameController,
                label: 'Ad Soyad',
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad Soyad boş olamaz';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                context: context,
                controller: _emailController,
                label: 'E-posta',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta boş olamaz';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi giriniz';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                context: context,
                controller: _birthdayController,
                label: 'Doğum Tarihi (GG.AA.YYYY)',
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // İsteğe bağlı
                  }
                  // Tarih formatı kontrolü
                  if (!RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
                    return 'Geçerli bir tarih formatı giriniz (GG.AA.YYYY)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              const SizedBox(height: 8),
              
              _buildGenderSelection(context),
              
              const SizedBox(height: 32),
              
              if (_isLoading)
                Center(child: PlatformCircularProgressIndicator())
              else
                PlatformElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Profili Güncelle'),
                  material: (_, __) => MaterialElevatedButtonData(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  cupertino: (_, __) => CupertinoElevatedButtonData(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Profil fotoğrafı seçme alanı
  Widget _buildProfilePhotoSelector() {
    String profileImageUrl = widget.user.profilePhoto;
    bool hasImage = (profileImageUrl.isNotEmpty && profileImageUrl != 'null') || _profileImageBase64 != null;
    
    return Center(
      child: GestureDetector(
        onTap: _isLoadingImage ? null : _pickProfileImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: !hasImage
                  ? platformThemeData(
                      context,
                      material: (data) => Colors.blue.shade100,
                      cupertino: (data) => CupertinoColors.activeBlue.withOpacity(0.2),
                    )
                  : null,
                shape: BoxShape.circle,
                image: hasImage
                  ? _profileImageBase64 != null
                    ? DecorationImage(
                        image: MemoryImage(
                          base64Decode(_profileImageBase64!.replaceFirst('data:image/jpeg;base64,', '')),
                        ),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      )
                  : null,
              ),
              child: _isLoadingImage
                ? Center(child: PlatformCircularProgressIndicator())
                : (!hasImage
                  ? Center(
                      child: Icon(
                        context.platformIcons.person,
                        size: 60,
                        color: platformThemeData(
                          context,
                          material: (data) => Colors.blue,
                          cupertino: (data) => CupertinoColors.activeBlue,
                        ),
                      ),
                    )
                  : null),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: platformThemeData(
                    context,
                    material: (data) => Colors.blue,
                    cupertino: (data) => CupertinoColors.activeBlue,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: platformThemeData(
                      context,
                      material: (data) => Colors.white,
                      cupertino: (data) => CupertinoColors.white,
                    ),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCupertino(context) ? CupertinoIcons.camera : Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Form alanı widget'ı
  Widget _buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return isCupertino(context)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              CupertinoTextFormFieldRow(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          )
        : TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: keyboardType,
            validator: validator,
          );
  }
  
  // Cinsiyet seçim widget'ı
  Widget _buildGenderSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Cinsiyet',
            style: platformThemeData(
              context,
              material: (data) => data.textTheme.titleMedium,
              cupertino: (data) => data.textTheme.textStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: isCupertino(context) 
              ? Border.all(color: CupertinoColors.systemGrey4) 
              : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildGenderOption(context, 'Belirtilmemiş', '0'),
              const Divider(height: 1),
              _buildGenderOption(context, 'Erkek', '1'),
              const Divider(height: 1),
              _buildGenderOption(context, 'Kadın', '2'),
            ],
          ),
        ),
      ],
    );
  }
  
  // Cinsiyet seçim opsiyonu
  Widget _buildGenderOption(BuildContext context, String label, String value) { // value parametresi String tipine değiştirildi
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            if (isCupertino(context))
              _selectedGender == value
                  ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                  : const SizedBox(width: 24)
            else
              Radio<String>( // Radio tipi String olarak değiştirildi
                value: value,
                groupValue: _selectedGender,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Şifre Değiştirme Ekranı
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final LoggerService _logger = LoggerService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // Şifre değiştirme işlemi
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      await context.read<ProfileViewModel>().updatePassword(
        currentPassword: _currentPasswordController.text,
        password: _newPasswordController.text,
        passwordAgain: _confirmPasswordController.text,
      );
      
      if (mounted) {
        final viewModel = context.read<ProfileViewModel>();
        if (viewModel.status == ProfileStatus.passwordChanged) {
          // Başarı mesajını platform uyumlu dialog ile göster
          _showSuccessDialog('Şifreniz başarıyla güncellendi');
        } else {
          setState(() {
            _errorMessage = _formatErrorMessage(viewModel.errorMessage);
          });
        }
      }
    } catch (e) {
      _logger.e('Şifre güncellenirken hata: $e');
      setState(() {
        _errorMessage = _formatErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Başarı mesajı diyalog olarak göster
  void _showSuccessDialog(String message) {
    showPlatformDialog(
      context: context,
      builder: (dialogContext) => PlatformAlertDialog(
        title: const Text('Başarılı'),
        content: Text(message),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text('Tamam'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Ana sayfaya dön
            },
          ),
        ],
      ),
    );
  }
  
  // API hata mesajını formatla ve kullanıcı dostu hale getir
  String _formatErrorMessage(String error) {
    // API'nin döndürdüğü özel hata mesajlarını kontrol et
    if (error.contains('en az 8 karakter') || 
        error.contains('en az 1 sayı') || 
        error.contains('en az 1 harf')) {
      return error;
    }
    
    // Mevcut şifre hatası
    if (error.contains('Mevcut şifreniz hatalı') || 
        error.contains('current password') || 
        error.contains('incorrect password')) {
      return 'Mevcut şifreniz hatalı. Lütfen kontrol ediniz.';
    }
    
    // Şifre eşleşmeme hatası
    if (error.contains('Şifreler eşleşmiyor') || 
        error.contains('passwordAgain') || 
        error.contains('passwords do not match')) {
      return 'Girdiğiniz yeni şifreler birbiriyle eşleşmiyor.';
    }
    
    // Genel hata
    return 'Şifre değiştirme işlemi sırasında bir hata oluştu. Lütfen tekrar deneyiniz.';
  }
  
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Şifre Değiştir'),
        material: (_, __) => MaterialAppBarData(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _updatePassword,
              tooltip: 'Kaydet',
            ),
          ],
        ),
        cupertino: (_, __) => CupertinoNavigationBarData(
          transitionBetweenRoutes: false,
          trailing: _isLoading 
          ? const CupertinoActivityIndicator()
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Kaydet'),
              onPressed: _updatePassword,
            ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: platformThemeData(
                      context,
                      material: (data) => Colors.red.shade100,
                      cupertino: (data) => CupertinoColors.systemRed.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: platformThemeData(
                        context,
                        material: (data) => Colors.red,
                        cupertino: (data) => CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                ),
              
              _buildPasswordField(
                context: context,
                controller: _currentPasswordController,
                label: 'Mevcut Şifre',
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mevcut şifrenizi girmelisiniz';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildPasswordField(
                context: context,
                controller: _newPasswordController,
                label: 'Yeni Şifre',
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Yeni şifrenizi girmelisiniz';
                  }
                  if (value.length < 8) {
                    return 'Şifre en az 8 karakter olmalıdır';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Şifre en az 1 rakam içermelidir';
                  }
                  if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                    return 'Şifre en az 1 harf içermelidir';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildPasswordField(
                context: context,
                controller: _confirmPasswordController,
                label: 'Yeni Şifre (Tekrar)',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifrenizi tekrar girmelisiniz';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              if (_isLoading)
                Center(child: PlatformCircularProgressIndicator())
              else
                PlatformElevatedButton(
                  onPressed: _updatePassword,
                  child: const Text('Şifreyi Güncelle'),
                  material: (_, __) => MaterialElevatedButtonData(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  cupertino: (_, __) => CupertinoElevatedButtonData(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Şifre alanı widget'ı
  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return isCupertino(context)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: controller,
                        obscureText: obscureText,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          border: null,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onToggleVisibility,
                      child: Icon(
                        obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (validator != null)
                Builder(
                  builder: (context) {
                    final error = validator(controller.text);
                    return error != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Text(
                              error,
                              style: const TextStyle(
                                color: CupertinoColors.systemRed,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
            ],
          )
        : TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
            validator: validator,
          );
  }
} 