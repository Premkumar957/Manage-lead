using { com.mycompany as db} from '../db/emplyeee';

service EmployeeService {

    entity Employees as projection on db.Employees {
        * 
    };
}


annotate EmployeeService.Employees with @(
    odata.draft.enabled: true
);