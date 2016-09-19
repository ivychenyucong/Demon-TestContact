//
//  ViewController.swift
//  TestContact
//
//  Created by ivy on 16/9/19.
//  Copyright © 2016年 ivy. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts

class ViewController: UIViewController ,CNContactPickerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 响应事件
    @IBAction func goToContact(sender: AnyObject) {
        let vc = CNContactPickerViewController()
        vc.delegate = self
        self.presentViewController(vc, animated: true) {
            
        }
    }
    
    
    @IBAction func newContact(sender: AnyObject) {
        
        //创建
        let contact = createNewContact()
        
        //存储
        saveContact(contact)
        
        //查找
        getContactPersonName("i")
        
        
    }
    
    @IBAction func getContact(sender: AnyObject) {
        
        getContactPersonFullName("a")
    }
    
    
    @IBAction func updateContract(sender: AnyObject) {
        //查找
        let contracts = getContactPersonName("i")
        
        //假设一定找到
        updateContact(contracts![0])
        
        
    }
    
    //MARK: 处理函数
    
    func saveContact( contact:CNMutableContact) -> Bool{
        let saveRequest = CNSaveRequest()
        saveRequest.addContact(contact, toContainerWithIdentifier: nil)
        let store = CNContactStore()
        if ((try? store.executeSaveRequest(saveRequest)) != nil) {
            return true
        }else{
            return false
        }
    }
    
    func updateContact (contact:CNContact)->Bool{
        let updatedContact = contact.mutableCopy()
        let newEmail = CNLabeledValue(label: CNLabelHome,
                                      value: "john@example.com")
        
        //这里要注意: 如果之前取key 的时候没取出对应的key,这里update要报异常
        //所以一定要取出来多少key,就更新多少key
        (updatedContact as! CNMutableContact).emailAddresses = [ newEmail]
        
        let saveRequest = CNSaveRequest()
        saveRequest.updateContact(updatedContact as! CNMutableContact)
        
        let store = CNContactStore()
 
        if ( (try? store.executeSaveRequest(saveRequest))  != nil){
            
            return true
        }else{
            return false
        }
    }
    
    func createNewContact()->CNMutableContact{
        let contact = CNMutableContact()
        
        //联系人头像
        let path = NSBundle.mainBundle().pathForResource("100.jpg", ofType: nil)
        contact.imageData = NSData(contentsOfFile: path!)
        
        //联系人姓名
        contact.givenName = "ivy"
        contact.familyName = "chen"
        
        //联系人email
        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "469202716@qq.com" )
        let workEmail = CNLabeledValue(label: CNLabelWork, value:"ivychen@xxxx.com")
        contact.emailAddresses = [homeEmail,workEmail]
        
        //联系人电话
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value:CNPhoneNumber(stringValue:"13000000000") )];
        
        //联系人住址
        let address = CNMutablePostalAddress()
        address.street = "zahojiabang 29#"
        address.city = "shanghai"
        address.state = "china"
        address.postalCode = "95032"
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome,
            value: address)]
        
        //生日
        let birthday = NSDateComponents()
        birthday.day = 1
        birthday.month = 4
        birthday.year = 1988 // can omit for a year-less birthday
        contact.birthday = birthday
        
        //打印
        
        //打印联系人姓名
        let fullName = CNContactFormatter.stringFromContact(contact,
                                                            style: .FullName)
        print(fullName)
        
        //打印联系人住址
        let postalString = CNPostalAddressFormatter.stringFromPostalAddress(address, style: .MailingAddress)
        print(postalString)
        
        return contact
    }
    
    func getContactPersonName(name:String) -> [CNContact]?{
        let predicate = CNContact.predicateForContactsMatchingName(name)
        // let keysToFetch = ["givenName", "familyName"]
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
        
        let store = CNContactStore()
        //仅作查看打印
        let status = CNContactStore.authorizationStatusForEntityType(.Contacts);
        print("\(status)")
        
        //store.requestAccessForEntityType(.Contacts){ b, e in
            
            let contacts = try? store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            
            for contact in contacts! {
                print("\(contact.givenName) \(contact.familyName)")
                
            }
        
        //}
    
        return contacts
    
    }
    
    
    
    func getContactPersonFullName(name:String){
        let predicate = CNContact.predicateForContactsMatchingName(name)
        
        //获取其所有的名字
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactEmailAddressesKey]
        
        let store = CNContactStore()
        
        let contacts = try? store.unifiedContactsMatchingPredicate(predicate,
                                                                  keysToFetch: keysToFetch)
        for contact in contacts! {
          let fullName =  CNContactFormatter.stringFromContact(contact, style: .FullName) ??  "No Name"
            
            print("\(fullName): \(contact.emailAddresses)")
            
        }
        
    }
    
    func getContactPhoneNumber(name:String){
        let predicate = CNContact.predicateForContactsMatchingName(name)
        // let keysToFetch = ["givenName", "familyName"]
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
        
        let store = CNContactStore()
        //仅作查看打印
        let status = CNContactStore.authorizationStatusForEntityType(.Contacts);
        print("\(status)")
        
        store.requestAccessForEntityType(.Contacts){ b, e in
            
            let contacts = try? store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            
            for contact in contacts! {
                print("\(contact.givenName) \(contact.familyName)")
                
                //没有取得的属性,并非真的不能取,拿到CNContact的identifier,就可以取出来它的所有属性
                if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                    print("\(contact.phoneNumbers)")
                } else {
                    let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey,
                                       CNContactPhoneNumbersKey]
                    
                    let refetchedContact = try? store.unifiedContactWithIdentifier(
                        contact.identifier, keysToFetch: keysToFetch)
                    
                    print("\(refetchedContact?.phoneNumbers)")
                    
                    //只取号码
                    let phoneNumValue =  refetchedContact?.phoneNumbers[0].value as? CNPhoneNumber
                    
                    print("\(  phoneNumValue?.stringValue)")
                    
                }

            }
        }
        
    }

   
    
    //MARK: CNContactPickerDelegate
    
    func contactPickerDidCancel(picker:CNContactPickerViewController){
        
    }
    
    func contactPicker(picker:CNContactPickerViewController, didSelectContact  contact: CNContact){
        print("did select contact")
        
        let vc = CNContactViewController(forContact:contact)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func contactPicker(picker:CNContactPickerViewController, didSelectContactProperty contactProperty:CNContactProperty){
         print("did select property")
    }

//    func contactPicker(picker:CNContactPickerViewController, didSelectContacts contacts: [CNContact]){
//        print("did select contacts")
//    }
//
//    func contactPicker(picker:CNContactPickerViewController, didSelectContactProperties contactProperties:[CNContactProperty]){
//        print("did select properties")
//    }
//


}

