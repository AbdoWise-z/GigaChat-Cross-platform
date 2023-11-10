enum ContactMethodType{
    EMAIL,
    PHONE,
}

class ContactMethod
{
    final ContactMethodType method;
    final String? data;
    final String title;
    final String disc;

    const ContactMethod({
        required this.method,
        required this.data,
        required this.title,
        required this.disc
    });
}