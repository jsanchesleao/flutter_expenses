import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function onDelete;

  TransactionList({@required this.transactions, @required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return transactions.isEmpty
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: <Widget>[
                  Container(
                    height: constraints.maxHeight * .1,
                    child: Text(
                      'No Transactions added yet',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  SizedBox(
                    height: constraints.maxHeight * .1,
                  ),
                  Container(
                    height: constraints.maxHeight * .6,
                    child: Image.asset(
                      'assets/images/waiting.png',
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              );
            },
          )
        : ListView.builder(
            itemBuilder: (ctx, index) {
              final tx = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 8,
                ),
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text('\$${tx.amount.toStringAsFixed(2)}'),
                      ),
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: Theme.of(context).textTheme.title,
                  ),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: mediaQuery.size.width > 460
                      ? FlatButton.icon(
                          icon: Icon(Icons.delete),
                          textColor: Theme.of(context).errorColor,
                          label: Text('Delete'),
                          onPressed: () => onDelete(tx.id),
                        )
                      : IconButton(
                          icon: Icon(Icons.delete),
                          color: Theme.of(context).errorColor,
                          onPressed: () => onDelete(tx.id),
                        ),
                ),
              );
            },
            itemCount: transactions.length,
          );
  }
}
