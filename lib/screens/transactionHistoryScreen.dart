import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

// Fonctions utilitaires pour le formatage
String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays == 0) {
    return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

String formatDateLong(DateTime date) {
  final months = [
    '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];
  
  return '${date.day} ${months[date.month]} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String formatAmount(int amount) {
  final str = amount.toString();
  final result = StringBuffer();
  
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      result.write(' ');
    }
    result.write(str[i]);
  }
  
  return result.toString();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedFilter = 'Tous';
  
  // Données simulées des transactions
  final List<Transaction> _allTransactions = [
    Transaction(
      id: 'TXN001',
      type: TransactionType.sent,
      amount: 25000,
      recipient: 'Koffi Adjovi (+22997123456)',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: TransactionStatus.completed,
      note: 'Remboursement',
      fees: 0,
    ),
    Transaction(
      id: 'TXN002',
      type: TransactionType.received,
      amount: 15000,
      recipient: 'Marie Soglo (+22996234567)',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: TransactionStatus.completed,
      note: 'Merci pour le service',
      fees: 0,
    ),
    Transaction(
      id: 'TXN003',
      type: TransactionType.withdrawal,
      amount: 50000,
      recipient: 'Agent WEMA - Cotonou Centre',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
      note: '',
      fees: 500,
    ),
    Transaction(
      id: 'TXN004',
      type: TransactionType.sent,
      amount: 10000,
      recipient: 'Ibrahim Zakari (+22995345678)',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: TransactionStatus.failed,
      note: 'Transport',
      fees: 0,
    ),
    Transaction(
      id: 'TXN005',
      type: TransactionType.deposit,
      amount: 75000,
      recipient: 'Agent MTN - Dantokpa',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: TransactionStatus.completed,
      note: '',
      fees: 0,
    ),
    Transaction(
      id: 'TXN006',
      type: TransactionType.sent,
      amount: 30000,
      recipient: 'Fatou Kone (+22594567890)',
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: TransactionStatus.pending,
      note: 'Frais scolaires',
      fees: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    switch (_selectedFilter) {
      case 'Envoyés':
        return _allTransactions.where((t) => t.type == TransactionType.sent).toList();
      case 'Reçus':
        return _allTransactions.where((t) => t.type == TransactionType.received).toList();
      case 'Retraits':
        return _allTransactions.where((t) => t.type == TransactionType.withdrawal).toList();
      default:
        return _allTransactions;
    }
  }

  void _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation du rechargement
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique mis à jour'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailsModal(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Historique',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _refreshTransactions,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec résumé
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryCard(
                      title: 'Ce mois',
                      amount: '285,000',
                      subtitle: '12 transactions',
                      icon: Icons.calendar_month,
                    ),
                    _SummaryCard(
                      title: 'Total envoyé',
                      amount: '65,000',
                      subtitle: '3 transferts',
                      icon: Icons.arrow_upward,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tous', 'Envoyés', 'Reçus', 'Retraits'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Colors.blue[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Liste des transactions
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _EmptyState(filter: _selectedFilter)
                : RefreshIndicator(
                    onRefresh: () async => _refreshTransactions(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _filteredTransactions[index];
                        return _TransactionCard(
                          transaction: transaction,
                          onTap: () => _showTransactionDetails(transaction),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount FCFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône du type de transaction
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: transaction.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Détails de la transaction
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.recipient,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Montant et statut
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isCredit ? '+' : '-'}${formatAmount(transaction.amount)} FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: transaction.isCredit ? Colors.green[600] : Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transaction.status.label,
                      style: TextStyle(
                        color: transaction.status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filter == 'Tous' 
                ? 'Vos transactions apparaîtront ici'
                : 'Aucune transaction de type "$filter"',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailsModal extends StatelessWidget {
  final Transaction transaction;

  const _TransactionDetailsModal({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle du modal
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction.type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.type.label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatDateLong(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Détails
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _DetailRow('ID Transaction', transaction.id),
                _DetailRow('Montant', '${formatAmount(transaction.amount)} FCFA'),
                if (transaction.fees > 0)
                  _DetailRow('Frais', '${formatAmount(transaction.fees)} FCFA'),
                _DetailRow('Destinataire/Source', transaction.recipient),
                if (transaction.note.isNotEmpty)
                  _DetailRow('Note', transaction.note),
                _DetailRow('Statut', transaction.status.label, 
                  valueColor: transaction.status.color),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Partager les détails
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reçu partagé')),
                    );
                  },
                  child: const Text('Partager'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Modèles de données
class Transaction {
  final String id;
  final TransactionType type;
  final int amount;
  final String recipient;
  final DateTime date;
  final TransactionStatus status;
  final String note;
  final int fees;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.recipient,
    required this.date,
    required this.status,
    required this.note,
    required this.fees,
  });

  bool get isCredit => type == TransactionType.received || type == TransactionType.deposit;
}

enum TransactionType {
  sent,
  received,
  withdrawal,
  deposit,
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.sent:
        return 'Envoi d\'argent';
      case TransactionType.received:
        return 'Argent reçu';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.deposit:
        return 'Dépôt';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.sent:
        return Icons.arrow_upward;
      case TransactionType.received:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.money_off;
      case TransactionType.deposit:
        return Icons.add_circle;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.sent:
        return Colors.red;
      case TransactionType.received:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.orange;
      case TransactionType.deposit:
        return Colors.blue;
    }
  }
}

enum TransactionStatus {
  completed,
  pending,
  failed,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Terminé';
      case TransactionStatus.pending:
        return 'En cours';
      case TransactionStatus.failed:
        return 'Échoué';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }
}