// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:medical_rep/core/styles/app_color.dart';
// import 'package:medical_rep/core/styles/app_text_style.dart';
// import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_cubit.dart';
// import 'package:medical_rep/features/visit_flow/presentation/cubits/active_visit/active_visit_state.dart';
//
//
// class VisitTasksCard extends StatelessWidget {
//   const VisitTasksCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ActiveVisitCubit, ActiveVisitState>(
//       buildWhen: (prev, curr) => prev.tasks != curr.tasks,
//       builder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: AppColors.whiteColor,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.blackColor.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Visit Tasks', style: AppTextStyle.subtitle),
//                   Text(
//                     '${state.completedTasks}/${state.tasks.length}',
//                     style: AppTextStyle.body.copyWith(color: AppColors.primaryColor),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: LinearProgressIndicator(
//                   value: state.taskProgress,
//                   minHeight: 6,
//                   backgroundColor: AppColors.lightgrayColor,
//                   valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ...state.tasks.map(
//                     (task) => _buildTaskItem(context, task),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTaskItem(BuildContext context, task) {
//     return GestureDetector(
//       onTap: () => context.read<ActiveVisitCubit>().toggleTask(task.id),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: task.isDone
//               ? AppColors.primaryColor.withOpacity(0.06)
//               : AppColors.lightgrayColor.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: task.isDone
//                 ? AppColors.primaryColor.withOpacity(0.2)
//                 : Colors.transparent,
//             width: 0.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: 22,
//               height: 22,
//               decoration: BoxDecoration(
//                 color: task.isDone ? AppColors.primaryColor : Colors.transparent,
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(
//                   color: task.isDone ? AppColors.primaryColor : AppColors.grayColor,
//                   width: 1.5,
//                 ),
//               ),
//               child: task.isDone
//                   ? const Icon(Icons.check, color: Colors.white, size: 14)
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 task.title,
//                 style: AppTextStyle.body.copyWith(
//                   color: task.isDone ? AppColors.primaryColor : AppColors.blackColor,
//                   decoration: task.isDone ? TextDecoration.lineThrough : null,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }