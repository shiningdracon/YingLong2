import MySQL
import mysqlclient

class MySQLPerfect: DatabaseProtocol {
    private var dataMysql: MySQL
    private var dataMysqlStmt: MySQLStmt

    init?(host hst: String, user: String, passwd: String, dbname: String) {
        dataMysql = MySQL()
        guard dataMysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8") else {
            return nil
        }
        guard dataMysql.setOption(.MYSQL_OPT_RECONNECT, true) else {
            return nil
        }
        guard dataMysql.connect(host: hst, user: user, password: passwd ) else {
            return nil
        }
        guard dataMysql.selectDatabase(named: dbname) else {
            return nil
        }
        dataMysqlStmt = MySQLStmt(dataMysql)
    }

    deinit {
        dataMysqlStmt.close()
        dataMysql.close()
    }

    private func execute(statement: String, params: [DatabaseValue]) -> Bool {
        guard self.dataMysqlStmt.prepare(statement: statement) else {
            return false
        }
        for param in params {
            switch param {
            case .int(let v):
                dataMysqlStmt.bindParam(v)
            case .uint(let v):
                dataMysqlStmt.bindParam(UInt64(v))
            case .string(let v):
                dataMysqlStmt.bindParam(v)
            case .double(let v):
                dataMysqlStmt.bindParam(v)
            case .null:
                dataMysqlStmt.bindParam()
            }
        }
        guard dataMysqlStmt.execute() else {
            return false
        }
        return true
    }

    func insert(statement: String, params: [DatabaseValue]) -> UInt? {
        if execute(statement: statement, params: params) {
            return dataMysqlStmt.insertId()
        }

        return nil
    }

    func update(statement: String, params: [DatabaseValue]) -> Bool {
        if execute(statement: statement, params: params) {
            return true
        }
        return false
    }

    func delete(statement: String, params: [DatabaseValue]) -> Bool {
        if execute(statement: statement, params: params) {
            return true
        }
        return false
    }

    func select(statement: String, params: [DatabaseValue]) -> [[String: Any]]? {
        if execute(statement: statement, params: params) {
            var ret = [[String: Any]]()
            let results = dataMysqlStmt.results()
            guard results.forEachRow(callback: {
                element in

                let fieldNames = dataMysqlStmt.fieldNames()
                if element.count != fieldNames.count {
                    return
                }
                var rowData = [String: Any?]()
                for i in 0..<element.count {
                    if let fieldname = fieldNames[i] {
                        rowData[fieldname] = element[i] //[Any?]
                    }
                }
                ret.append(rowData)
            }) else {
                return nil
            }
            return ret
        }

        return nil
    }

    func clear() {
        dataMysqlStmt.reset()
        dataMysqlStmt.freeResult()
    }

    func transactionStart() {
        let _ = dataMysql.query(statement: "START TRANSACTION")
    }

    func transactionCommit() {
        let _ = dataMysql.query(statement: "COMMIT")
    }

    func transactionRollback() {
        let _ = dataMysql.query(statement: "ROLLBACK")
    }
}
