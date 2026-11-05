class GivePage extends StatelessWidget {
  const GivePage({super.key});

  static const bank = 'Fidelity Bank';
  static const accName = 'Micheal Owowa';
  static const accNumber = '6011920596';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionCard(
          title: 'Give with a cheerful heart',
          child: Text('Your tithes and offerings support the work of the ministry.'),
        ),
        SectionCard(
          title: 'Bank transfer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank: $bank'),
              const Text('Account name: $accName'),
              const Text('Temporary ministry account'),
              const Text('Account number: $accNumber',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: accNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account number copied')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy account number'),
              ),
            ],
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Online card payment (Paystack) coming soon')),
          ),
          child: const Text('Give online (coming soon)'),
        ),
      ],
    );
  }
}
