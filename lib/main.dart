import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './widgets/chart.dart';
import './models/transaction.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      home: MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
            title: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            button: TextStyle(
              color: Colors.white,
              fontSize: 16,
            )),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                title: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;

  void _addNewTransaction(String txTitle, double txAmount, DateTime date) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: date,
      id: DateTime.now().toString(),
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (builderContext) {
        return FractionallySizedBox(
          heightFactor: MediaQuery.of(ctx).orientation == Orientation.portrait
              ? 0.6
              : 0.9,
          child: NewTransaction(
            onAdd: _addNewTransaction,
          ),
        );
      },
    );
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions
        .where(
          (tx) => tx.date.isAfter(
            DateTime.now().subtract(
              Duration(days: 7),
            ),
          ),
        )
        .toList();
  }

  double _getPercentageHeight(
      PreferredSizeWidget appBar, MediaQueryData mediaQuery, int percentage) {
    return ((mediaQuery.size.height -
                mediaQuery.viewPadding.top -
                appBar.preferredSize.height) *
            percentage) /
        100;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Personal Expenses'),
            trailing: GestureDetector(
              onTap: () => _startAddNewTransaction(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(CupertinoIcons.add),
                ],
              ),
            ),
          )
        : AppBar(
            title: Container(
              child: Text(
                'Personal Expenses',
                textAlign: TextAlign.left,
              ),
              width: double.infinity,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );

    final transactionListWidget = Container(
      height: _getPercentageHeight(appBar, mediaQuery, 70),
      child: TransactionList(
        transactions: _userTransactions,
        onDelete: _deleteTransaction,
      ),
    );

    final chartWidget = Container(
      height: _getPercentageHeight(appBar, mediaQuery, isLandscape ? 70 : 30),
      child: Chart(
        recentTransactions: _recentTransactions,
      ),
    );

    final bodyWidget = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LandscapeWidget(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Show Chart', style: Theme.of(context).textTheme.title),
                  Switch.adaptive(
                      activeColor: Theme.of(context).accentColor,
                      value: _showChart,
                      onChanged: (v) => setState(() {
                            _showChart = v;
                          }))
                ],
              ),
            ),
            LandscapeWidget(
              child: _showChart ? chartWidget : transactionListWidget,
            ),
            PortraitWidget(
              child: chartWidget,
            ),
            PortraitWidget(
              child: transactionListWidget,
            )
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: bodyWidget,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyWidget,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? SizedBox.shrink()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}

class LandscapeWidget extends StatelessWidget {
  final Widget child;
  LandscapeWidget({@required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? child
        : SizedBox.shrink();
  }
}

class PortraitWidget extends StatelessWidget {
  final Widget child;
  PortraitWidget({@required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? child
        : SizedBox.shrink();
  }
}
