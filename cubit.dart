//import 'dart:html';

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_project/shared/cubit/states.dart';
import 'package:my_first_project/shared/network/local/cache_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit():super(AppInitialStates());

  static AppCubit get (context)=> BlocProvider.of(context);

  int currentIndex=0;
  List<Widget> screens=
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles=
      [
        'New Tasks',
        'Done Tasks',
        'Archived Tasks',
      ];
  void changeIndex (int index){
    currentIndex=index;
    emit(AppChangeBottomNavBar());
  }
  late Database database;

  List<Map> newTasks=[];
  List<Map> doneTasks=[];
  List<Map> archiveTasks=[];

  void createDatabase()
  {
   openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database,version)
      {
        print('database created');
        database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)').then((value)
        {
          print('table created');
        }
        ).catchError((error){

          print('error when creating ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        GetDataFromDatabase(database);

        print('data is opened');
      },
    ).then((value) {
     database = value;
     emit(AppCreateDataBaseState());
   }
    );
  }


    insertToDatabase ({
    required String title,
    required String time,
    required String date,
  }) async {
     await database.transaction((txn) async  {
      txn.rawInsert('INSERT INTO tasks (title,date,time,status) values ("${title}","${date}","${time}","new")')
          .then((value) {
        print('${value} inserted successfully');
        emit(AppInsertDataBaseState());

        GetDataFromDatabase(database);
      }).catchError((error) {
        print('error when inserting ${error.toString()}');
      });
      return null;
    });
  }

   GetDataFromDatabase(database)
  {
    newTasks=[];
    doneTasks=[];
    archiveTasks=[];
    emit(AppGetDataBaseLoadingState());
     database.rawQuery('SELECT * FROM tasks').then((value)
     {
     value.forEach((element){
       if(element['status']=='new'){
         newTasks.add(element);
       }else  if(element['status']=='Done')
         doneTasks.add(element);
       else archiveTasks.add(element);
     });

       emit(AppGetDataBaseState());
     }
     );

  }

  void UpdateData({
    required String status,
    required int id,
})async
  {
     database.rawUpdate(
      'UPDATE tasks SET status=? WHERE id=?',
      ['$status',id],
    ).then((value) {
      GetDataFromDatabase(database);
      emit(AppUpdateDataState());
     });


  }
  
  void DeleteData({
    required int id,
}){
    database.rawDelete('DELETE FROM tasks WHERE id=?',[id])
     .then((value)
    {
      GetDataFromDatabase(database);
      emit(AppDeleteDataState());
    }
    );
}

  bool isBottomSheetShown=false;
  IconData FabIcon=Icons.edit;

  void ChangeBottomSheetState({
    required bool isShow,
    required IconData icon,
}){
    isBottomSheetShown=isShow;
    FabIcon=icon;

    emit(AppChangeBottomSheetState());
  }

    bool isDark=false;
  void changeMode({fromShared}){
    if(fromShared!=null){
      isDark=fromShared;
      emit(AppChangeModeState());
    }
    else{
      isDark=!isDark;
      CacheHelper.putBoolean(key: 'isDark', value: isDark).then((value){
        emit(AppChangeModeState());
      }
      );
    }


  }
}