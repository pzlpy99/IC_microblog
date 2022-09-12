import Iter "mo:base/Iter";
import List "mo:base/List";
import Microblog "mo:base/Principal";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
actor {
    public type Message = {
        content : Text;
        time : Time.Time;
    };
    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared (Text) -> async ();
        posts: shared query (Int) -> async [Message];
        timeline: shared () -> async [Message];
    };
    var followed : List.List<Principal> = List.nil(); 
    public shared (msg) func follow(id : Principal) : async (){
        // assert(Principal.toText(msg.caller)) == "vnxq2-nmrus-thmuq-hohfk-nnrim-day4h-dnfnu-eoey6-4wnrj-cf4ou-hae";
        followed := List.push(id,followed);
    };
    public shared query func follows() : async [Principal]{
        List.toArray(followed)
    };
    var messages : List.List<Message> = List.nil();
    public shared (msg) func post(text : Text) : async () {
        let message : Message = { content=text; time = Time.now()};
        // assert(Principal.toText(msg.caller)) == "vnxq2-nmrus-thmuq-hohfk-nnrim-day4h-dnfnu-eoey6-4wnrj-cf4ou-hae";
        messages := List.push(message, messages)
    };
    public shared query func posts(since: Time.Time) : async [Message]{
        var res : List.List<Message> = List.nil();
        for(msg in Iter.fromList(messages)){
            if(msg.time > since){
                res := List.push(msg, res);
            };
        };
        List.toArray(res)
    };

    public shared (msg) func timeline(since: Time.Time) : async [Message] {
        // assert(Principal.toText(msg.caller)) == "vnxq2-nmrus-thmuq-hohfk-nnrim-day4h-dnfnu-eoey6-4wnrj-cf4ou-hae";
        var msgs : List.List<Message> = List.nil();
        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let ms = await canister.posts(since);
            for (msg in Iter.fromArray(ms)) {
                msgs := List.push(msg, msgs);
            }
        };
        List.toArray(msgs);
    };
};

