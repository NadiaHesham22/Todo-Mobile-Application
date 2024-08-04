import 'dart:async';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_first_project/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:my_first_project/modules/done_tasks/done_tasks_screen.dart';
import 'package:my_first_project/modules/new_tasks/new_tasks_screen.dart';
import 'package:my_first_project/shared/components/components.dart';
import 'package:my_first_project/shared/cubit/cubit.dart';
import 'package:my_first_project/shared/cubit/states.dart';
import 'package:sqflite/sqflite.dart';

import '../../shared/components/constants.dart';

//const HomeLayout({super.key});


class HomeLayout extends StatelessWidget
{


   var scaffoldKey=GlobalKey<ScaffoldState>();
   var formKey=GlobalKey<FormState>();
   var titleController=TextEditingController();
   var timeController=TextEditingController();
   var dateController=TextEditingController();




  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context)=>AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (BuildContext context,AppStates state){
          if(state is AppInsertDataBaseState){
            Navigator.pop(context);
          }
        },
          builder:(BuildContext context,AppStates state){
          AppCubit cubit =AppCubit.get(context);
          return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
          title: Text(
            cubit.titles[cubit.currentIndex],
          ),
          ),
          body: ConditionalBuilder(
          condition: state is ! AppGetDataBaseLoadingState,
          builder: (context)=>cubit.screens[cubit.currentIndex],
          fallback: (context)=> Center( child: CircularProgressIndicator()),
          ),
          floatingActionButton: FloatingActionButton(
          onPressed: () {

          //insertToDatabase();
          if(cubit.isBottomSheetShown){
          if(formKey.currentState!.validate()){
            cubit.insertToDatabase(title: titleController.text,
                time: timeController.text,
                date: dateController.text,
            );
          // insertToDatabase(title: titleController.text,
          // time: timeController.text,
          // date: dateController.text,
          // ).then((value) {
          // GetDataFromDatabase(database).then((value)
          // {
          // Navigator.pop(context);
          // // setState(() {
          // //   isBottomSheetShown=false;
          // //     FabIcon=Icons.edit;
          // //   tasks=value;
          // // });
          //
          // }
          // );
          // });
          }
          }else{
          scaffoldKey.currentState?.showBottomSheet(
          (context) =>Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
          key: formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          defaultFormField(
          controller: titleController,
          type: TextInputType.text,
          validate: (value) {
          if (value!.isEmpty) {
          return 'Title must not be empty';
          }
          return null;
          },
          label: 'Task Title',
          prefix: Icons.title,
          ),
          SizedBox(
          height: 15.0,
          ),
          defaultFormField(
          controller: timeController,
          type: TextInputType.datetime,
          onTap: (){
          showTimePicker(context: context,
          initialTime: TimeOfDay.now(),
          ).then((value) {
          timeController.text=value!.format(context).toString();
          //print(value?.format(context));
          });
          },
          validate: (value) {
          if (value!.isEmpty) {
          return 'Time must not be empty';
          }
          return null;
          },
          label: 'Task Time',
          prefix: Icons.watch_later_outlined,
          ),
          SizedBox(
          height: 15.0,
          ),
          defaultFormField(
          controller: dateController,
          type: TextInputType.datetime,
          onTap: (){
          showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime.parse('2024-09-01'),
          ).then((value) {
          dateController.text=DateFormat.yMMMd().format(value!);
          });
          },
          validate: (value) {
          if (value!.isEmpty) {
          return 'Date must not be empty';
          }
          return null;
          },
          label: 'Task Date',
          prefix: Icons.calendar_month,
          ),
          ],
          ),
          ),
          ),
          ).closed.then((value)
          {

          cubit.ChangeBottomSheetState(
            isShow: false,
            icon: Icons.edit,
          );

          }
          );
          cubit.ChangeBottomSheetState(
            isShow: true,
            icon: Icons.add,
          );
          }
          },
          child: Icon(
          cubit.FabIcon,
          ),
          ),
    bottomNavigationBar: BottomNavigationBar(
    type:BottomNavigationBarType.fixed,
    currentIndex: cubit.currentIndex,
    onTap: (index){
      cubit.changeIndex(index);
    },
    items:
    [
    BottomNavigationBarItem(
    icon:Icon(
    Icons.menu,
    ),
    label: 'Tasks',
    ),
    BottomNavigationBarItem(
    icon:Icon(
    Icons.check_circle_outline,
    ),
    label: 'Done',
    ),
    BottomNavigationBarItem(
    icon:Icon(
    Icons.archive_outlined,
    ),
    label: 'Archived',
    ),
    ],
    ),
    );
    },

      ),
    );


  }



}
