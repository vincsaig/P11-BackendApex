global class Batch01Schedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
       Batch01AccountChiffreAffaire b = new Batch01AccountChiffreAffaire(); 
       database.executebatch(b);
    }
 }
