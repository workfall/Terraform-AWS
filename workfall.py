#!/usr/bin/python3.6
import urllib3 
import json
import urllib.request, urllib.parse
http = urllib3.PoolManager() 

def workfall_notification(subject,msg,region):
    ## this will be used to specify color outline based on alarm state value
    color_states = {'OK': '00FF00', 'INSUFFICIENT_DATA': 'FFFF00', 'ALARM': 'FF0000'}
    
    return {
            "@type": "MessageCard",
            "@context": "http://schema.org/extensions",
            "themeColor": color_states[msg['NewStateValue']],
            "title": "Workfall Cloudwatch Notification- " + subject,
            "text": "Alarm {} triggered".format(msg['AlarmName']),
            "sections": [
                { "activityTitle": "Alarm Name", "activitySubtitle": msg['AlarmName'] },
                { "activityTitle": "Alarm Description", "activitySubtitle": msg['AlarmDescription']},
                { "activityTitle": "Alarm reason", "activitySubtitle": msg['NewStateReason']},
                { "activityTitle": "Old State", "activitySubtitle": msg['OldStateValue'] },
                { "activityTitle": "Current State", "activitySubtitle": msg['NewStateValue']},
                                
                ],

            "potentialAction": [{
                    
                 "@type": "OpenUri",
                 "name": "Link to Alarm",
                 "targets": [{
                        "os": "default",
                        "uri": "https://console.aws.amazon.com/cloudwatch/home?region=" + region + "#alarm:alarmFilter=ANY;name=" + urllib.parse.quote_plus(msg['AlarmName'])}]
        
            }]         
                               
                                     
    }
     
    
def lambda_handler(event, context): 
    subject = event['Records'][0]['Sns']['Subject']
    region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]
    msg = event['Records'][0]['Sns']['Message']
    msg = json.loads(msg)
    url = ""    ##add your webhook url here
    encoded_ms = workfall_notification(subject,msg,region)
    encoded_ms = json.dumps(encoded_ms).encode('utf-8')        
    print(msg)
    resp = http.request('POST',url, body=encoded_ms)  
    print(resp)     
    return msg