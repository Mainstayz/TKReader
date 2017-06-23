//
//  TKBookViewController.swift
//  Tricky
//
//  Created by Pillar on 2017/6/19.
//  Copyright © 2017年 unkown. All rights reserved.
//

import UIKit
import FontAwesomeKit


class TKBookViewController: TKViewController {

    
    var bookView : TKBookView?
    var isHiddenToolViews : Bool = true
    var aNavigationBar : UINavigationBar?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let bar = UINavigationBar(frame: CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: 64))
        
        let arrowLeftIcon = FAKFontAwesome.angleLeftIcon(withSize: 30)
        arrowLeftIcon?.addAttribute(NSForegroundColorAttributeName, value: TKBookConfig.sharedInstance.textColor)
        let arrowLeftImage = arrowLeftIcon?.image(with: CGSize(width: 24, height: 30)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
//        let backItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(back))
        let backItem = UIBarButtonItem(image: arrowLeftImage, style: .plain, target: self, action: #selector(back))
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = backItem
        bar.pushItem(navItem, animated: false)
        bar.barTintColor = TKBookConfig.sharedInstance.backgroundColor
        self.aNavigationBar = bar

        
        let str = "坦白说，作为一个内向的人，我没什么资格说这个话题。\n9年以前，我都还是一个习惯性地在人多的饭桌上低头吃饭，全无存在感的人。内向这个词儿那时候对我来说是一层安全的保护伞，让我与这个世界都始终隔着点什么。\n或许很多人从小就和我一样，被教育成要做一个老实的孩子，老实就意味着要少说话，不招摇，少表现，你要和所有普通的大多数一样。这个观念让我学会了遇事不要出风头，别总是人前炫耀，我原本以为那些爱嘚瑟的人最后也会和我一样碌碌无为，但好像并不是那样，他们提早比我出过了风头，提早比我体会到了失败和教训，他们对痛苦和挫折的承受力是我的几倍，而不知道从什么时候起，我开始越来越怕，怕改变，怕不确定，怕犯错，怕被人指责，我变得越来越喜欢活在自己的小世界里。\n有时候我也不是我也不是不羡慕，看着和我同批进公司的同事一路成长，看着他们能一面搞定客户，一面和上司侃侃而谈，我也羡慕嫉妒恨，但内心里总有一个小小、自卑的自己对我说：羡慕有什么用？我和人家又不一样，有些事我根本就做不到。\n因为内向，我对新环境的融入程度总会比其他人来得更长一些，我总是给自己找理由称这是慢热，但直到我入职半年，许多同事都还对我没印象的时候，我才发现，其实或许不是同事不能记得我，而是我从一开始就没有给对方留下深刻的记忆点。\n内向带来的最大的麻烦是沟通。\n明明只要几句话就可以把核心问题圈定出来，我却因为不敢问，或者是忌惮对方强势的气场，最后默默加了很多冤枉的班，搞错了很多方向，往往需要花两倍的时间才能搞定一个小事情，收获的除了挫败感之外，还有对自己深深的懊恼和看不起。\n内向带来的第二个麻烦是让你投了逃避的借口。\n有段时间我已经习惯性地把内向当做工作做得不好，职场人缘不好的理由，反正因为我本来就是一个内向的人，所以才会这么的不讨人喜欢吧？\n内向，没有帮助我建立任何自信，反倒是蚕食掉了我所有的信心。\n那时候我已经是一个工作了五年的老人，职场上混的完全没有任何起色，我没有目标、也不知道自己能干什么、会什么，有时候我甚至都不知道，如果有一天我被公司开除了，我还能做什么？哪个公司还会要我。\n不论是对自己，还是对人生都充满了丧气和绝望，或许我这辈子也就这样了吧！我真的曾经这样想过。\n如果不是因为奥运会那年的金融危机，全行业大裁员，我或许不会被震醒。\n那一年我们公司也遭遇了大裁员，我一直都担心我会被裁掉，因为当危机来临的时候我环顾了一下周遭的同事，对比之后才发现，我的存在感最低，我很可能会被当做最无用的那个人被裁掉。那阶段我特别焦虑，直到后来通知出来，发现是我的直属领导被裁掉，才长出了一口气，但原本的部门被解散，我也被迫合并到了公关部。\n公关部是一个靠说话才能活下去的地方，面对领导要说话，面对客户要说话，面对供应商你也一样要说话。我记得我第一次去活动现场，带我的人只对我说了二十分钟的话就忙自己的事情去了，我一个人要对接现场的6个供应商，从桌椅的摆放到鲜花和音响，每个人都要来问我的意见，这时候逃避没有用，即便我内心再害怕，都只能硬着头皮迎头赶上。\n那时候我资历最浅，负责最远、周期最长的项目跟踪，我精神高度紧张，每晚失眠，我要随时面对现场可能出现的各种各样的问题，第一时间想到解决办法。有段时间忙完一天的活动在打车回去的路上我就忍不住鼻子酸酸的，我总觉得自己辛苦的不是身体，而是内心有一种别扭，我为什么非要做自己不喜欢、不擅长的事呢？我这么委屈自己到底是为了什么？\n我内心里知道答案，因为现在经济形势不好，工作也不好找，我如果辞职肯定会找不到工作，我只能忍，别无选择。\n让我做出改变决定的是有一天我忙完了又一场鸡飞狗跳的活动之后，回去的车上打开手机看到日历才发现今天是自己三十岁的生日，回到住处的时候已经晚上十点多了，我在楼下的小吃摊点了一碗青菜面，给自己过了最简单的一个生日，那时我对自己说，我前三十年都活得的那么窝囊，从明天起，我想活得不一样一些，既然现在我决定不了未来的方向，那不如就接受这个安排，鼓起勇气，和它拼一个你死我活！\n我从没想过要一夜之间打碎那个内向的自己，我为自己做了三个方面小的提示。\n1.调整心态和看问题的角度。\n以前我很讨厌变化和不确定，因为我总是担心会出现什么意外是自己无法解决的，后来我问自己，即便你搞砸了，又能怎样？你最多就是挨领导的一顿骂，你会因此丢了工作么？\n即便你丢了，你去下一份工作，你依旧还是要去解决类似的问题，所以不要因为怕挨骂，就祈祷问题不出现，而是要多想想，如果问题出现了，我能不能给出两个以上的解决办法。\n哪怕这两个办法不可行，至少我实验过了，下次遇到同类型的问题，我离找到正确答案的几率又多了百分之二。\n我以前总觉得所有遇到的问题是敌人，如果换个角度，或许我所有遇到的问题其实都是考题，我做对了，我就积累的分数和经验值，那我为什么不期待有更多的问题出现，解决的越多，升级才越快啊！\n2.做出第一步，从一个小目标开始。\n改变不容易，我从一开始就知道，所以为了让自己能鼓起勇气去改变，做和昨天\n不一样的自己，我换了一条去公司的路，每次一踏上这条路我就提示自己，今天的你已经不一样了。\n我给自己定了一个小任务，每天早晨最少和公司的十位同事打招呼，哪怕说句你好都可以。\n每天中午强迫自己必须和大家一起吃工作餐，吃饭的时候不再低头，不论别人说什么，都要至少能让自己有机会说上五句话。\n3.善用小仪式，赶走怨气获得源动力\n改变最开始的时候一定是最痛苦的，尤其是当你不得章法屡屡受挫的时候，这时候换心情调整角度是必要的，但是如果这两招都不那么奏效，或许你还需要自带一个“充电宝”。\n我自己的充电宝其实就是寻找自己内心里你觉得最高大上的样子，找一个东西去和内心里那个你觉得无所不能的自己去做连接，我用的是领带。\n因为我一直都特别羡慕那些影视剧里穿正装的白领，他们专业到位，特别精英范儿，我一直都羡慕，希望有一天能像他们一样。但是公司里大家也没有谁穿正装，我当时还没有勇气搞一身西服过去，于是就折中了一下，选择了领带。\n别小看这一条破带子，每次为了打好它我至少都需要提前预留出15分钟才行，在一遍一遍对着镜子打领带的过程里，我看着镜子里的自己，一点点变得像我想象的那些精英一样，专业、自信、有气场，基本上这大半天都能维持元气满满的状态。\n打上领带之后，我做事应对的方式也逐渐从原来苦着脸说我不行，到后来开心地说我试试。我想，就是这么一点一滴，积沙成达，把每一滴自己的闪光汇聚到了一起，或许才逐渐变成了后来那个叫做“自信”的东西吧！\n时至今日，我也不敢说自己是一个特别外向的人，但是至少我现在敢说，我已经不再是早年那个自卑内向的自己，我敢说、敢表达，我敢拒绝，敢决策，希望以上我分享的这些关于内向的种种，能对你有点帮助。"
        
        
        let str1 = "现在越来越多的新人选择了旅拍婚纱照这种方式，但是很多人对旅拍却并不怎么理解，经常会问到旅拍一般多少钱和旅拍的价格行情之类的问题，但其实除了要让专业的团队更随拍婚纱照，如果自己去拍的话基本只要一些旅游基本费用，那么接下来就请大家看宁波婚纱摄影哪家好的小编做的旅拍婚纱照四种方式及攻略的具体内容。\n1、在本地影楼的异地连锁店拍摄\n目前全国有不少提供此类服务的连锁婚纱摄影机构，这些机构在全国各地拥有连锁分店，而且较多都是设在大城市以及风景名胜地，加上拥有丰富的旅游婚纱拍摄经验，可以为外地新人提供当地特色的婚纱拍摄服务。这样一来，新人们只要轻装上阵就可以到心仪的目的地拍摄婚纱照了。\n操作方式：\n到本地工作室沟通和确定旅拍目的地和方案，本地工作室会把新人的要详细的传达给与目的地的连锁店，安排好具体的拍摄时间和计划，新人到达目的地后与他们联系即可。\n相关费用：\n这种形式的旅拍，由于都是采用目的地的拍摄人员，新人不需要支付工作人员的路费、住宿费，但景区门票有可能需要新人负责，另外，目的地工作室不负责新人的食宿、往来路费，新人需要自己订酒店安排往返交通等。\n优点：新人到了外地人生地不熟，连锁店就相对好找有保障，有跟妆有婚纱出租有包车，后期服务联络方便。\n缺点：由于拍摄前的沟通是与本地影楼，执行是在异地分店，所以拍摄时容易出现问题。\n2、本地工作室随行的旅游婚纱照\n“一对一”的高级定制，由婚纱影楼为新人度身定制的服务，从线路、行程安排，到摄影风格、服装、化妆等细节都由影楼根据新人们的具体要求设计。这项服务需要由新人支付随行摄影师、化妆师、助理的机票、住宿等费用，价格较高。\n操作方式：\n联系可以提供随行旅拍的本地工作室，提出想法和要求，然后由工作室的专业人士设计方案，并算出价格，双方达成协议后便可依照约定日程出行。一般预订机票、酒店等事宜都是影楼来代办，新人也可以选择自己喜欢的住宿地，但需要跟工作室协商，一是费用会有所增减，二是要考虑住宿地与拍摄地之间的交通情况。\n相关费用：新人需要负责所有随行工作人员的一切费用，一般每一对新人会配备一个化妆师、一个摄影师和一个助理，共五个人出行。比如去塞班岛全程4日，包括机票、住宿等费用，共需2万元到3万元左右。\n优点：工作人员随行，绝对的明星般出国拍大片的服务享受，新人可以很省心，由于前后期沟通详细，照片质量也更有保障。\n缺点：费用高，新人需要支付所有随行人员的吃住行开支，适合最求完美预算又丰富的新人。";

        let str2 = "女友说朋友圈里某些人点赞和打卡一样，无论自己发了什么，那些人都会蜂拥而上一通点赞，但是真让他们去别的地方点一下，或者帮忙投个票之类，这些人肯定不去。我说首先别人好像也没有义务一定要给你去投票或者点赞的，点了呢，是人情，你铭记心中，由衷感激；不点呢，那是他们的权利，难道你还能勉强他们吗？这种事真的不必当真。\n不过女友形容的那种人，你一定也见过吧，在朋友圈里点赞，你肯定是第一时间会看到，白屏红心昭然若揭，犹如挂在城头上示众的人头，亮晃晃的刺人眼目，又似夜里的一盏红灯笼，明晃晃的，似乎在向你招手，又似乎是在对你说：你好呀你好，你看，我是你的朋友，我给你点赞了哦。\n这时候，你可千万别以为他们是真的喜欢你，赞同你，同意你的观点，或者在夸你发的自拍照“可美了”，做的菜很“色香味俱全”，旅行的地方“老诱人了，老诗和远方了，老不苟且了”，不是的，很多时候，他们可能连看也不想看你发的那些东西，他们的点赞只不过是在说：我点了红心了，我到你这里来应酬过了，人际关系需要经营，那我现在就来经营一下吧，反正动动手指也不需要花什么力气和成本，而且还有利身体健康，老了不会得老年痴呆外加手指僵硬症。\n\n但是，你若发一个倡议，让大家去另一个地方给你点赞投票什么的，有的人就不愿意去——这也很可以理解。因为要登陆啊，哪怕是用自己的QQ登陆，也是很麻烦的，人家为什么要为了你这么麻烦，你和TA交情够吗？按郭德纲这帮说相声的人的说法是：“我和你过得着这个吗”，是啊，咱俩过得着吗爷们儿？\n也有朋友和我说过，他在群里发红包请人去投票，有好几个人抢了红包，却没有去投票——他们以为对方是不知道自己有没有投过票的，其实对方知道，肚子里跟吃了萤火虫一样（天哪，这世上竟还有这么“纯真幼稚”，思维超感人的小可爱们），他说自己也不作声，反正发个红包也是小事，花点小钱看清那些人，挺值的。\n这个嘛，我也只能说，第一，我不会去抢红包，假如我抢了，哪怕只有一分钱，我也会去投票。为什么？谁让我手欠去抢的，一分钱和一万块在某些时候同等值，古人说过，食君之禄，担君之忧，我拿了你的红包，我就得去办事儿，要么就不要拿。\n但有的人的逻辑是这样的，发红包是你自己手欠要发，我请你发啦？本来就是玩玩的嘛，谁说拿了你的钱就一定要给你办事儿啊？凭什么呀，你还别那么叽叽歪歪别较真儿，爷把钱退给你行不，瞧你那小家子气——行，这个逻辑也很说得通。确实，并不是我（或某个人）的行为规范才是对的。别人认为他们也很对，也成，也说得通。但，至少我本人不会那么做。\n我常常说，有人微信里竟然有几千个“朋友”——刻意经营为了做生意，圈粉的除外——普通人假若“微信朋友”有几千个，几百个，那TA肯定没有一个真正的朋友，越是缺什么，就越是要去找什么嘛，其实找来找去，也只找来了一大堆“点赞”，当不得吃，当不得穿，当然人活着不是只为了吃穿，可也解除不了孤独与寂寞，甚至有时你只想找个人聊聊天，你那几千几百个“朋友”，却是谁也陪不了你唠一场如你心愿的嗑儿。\n\n有不少人是和我一样，手欠要去当作者的（当然作者同时也是读者，我们都给自己真正喜欢的文章，非常真诚地点过赞），但有时候，有人一口气给你每篇文章都点了赞，看好了，那很有可能不是你的铁粉，不是Ta“爱死你”了（他是尔康，你是晴儿的可以除外），而是，他点赞不过是给驴面前挂一个胡萝卜，先给你点甜头尝尝，为的是要你也去给他回赞——当然不是所有人都这样，但这样要互相交换红心的奇景也是一直存在的。我自己就遇到过一个奇葩，记得刚来此地发文时，有一个陌生人来我这儿刷刷刷在几秒内点了三个赞，把我给看愣了，感激涕零，心中默念此位知音大叔到底为谁？后来一看他点赞的速度，就知道他应该连一个字都没有读过就点了，我想自己还没有混到让人一看作者名就齐刷刷给每篇文章都点赞的高度，也就一笑了之。\n没想到过了半天，那一位见我没给他回礼，没去他那里回赞，来而不往非礼也，真心觉得我是一个没有礼貌的野人，他又迅速地撤回了“赞”——你问我怎么发现是他撤回的，很简单，比如你刚开始发文，一共也只有三个赞，对方撤回了，你的点赞数为零，这就好比你刚拿了一个空碗去地铁口要饭，碗里也不过是三个钢镚儿，一下子别人全拿走了，你还能不知道吗。对于这一位，连那么虚幻之极的“点赞”都如此斤斤计较，点了又能果断撤回，果断止损，我们可以想象他在真实生活中是怎样一副嘴脸了吧，这样的人怎么可以做朋友？避之唯恐不及。\n记起前几天看过一篇文章，提出一个观点，说是“千万不要让朋友圈集点赞这类破事儿，耗光你的人情”，他说的也挺对，但从另一个角度想，朋友圈里那几千几百个“朋友”（真正的，经得起时光考验的知己除外），你和他们积攒多年的“人情”，除了“点赞”之外，还能够得上什么？够得上借钱买房不（高息借贷除外）？够得上不开心时半夜打电话倾诉十五分钟不？够得上“开轩面场圃，把酒话桑麻”不？够得上“五花马，黄金裘，呼儿将出换美酒，与尔同销万古愁”不？肯定够不上，统统都够不上，所以，大家还是手捧一个小红心，互相点赞热闹往来，那种衣香鬓影鱼雁穿梭，感觉自己有朋友，有人脉，有圈子的浮华光影，点缀出一大片如花似锦的虚假繁荣来，也是“不亦悦乎”呢。";
        
        
        let attStr = NSAttributedString(string: str, attributes: TKBookConfig.sharedInstance.attDic)

        self.automaticallyAdjustsScrollViewInsets = false
        
        self.bookView = TKBookView(frame: self.view.bounds)
        self.bookView?.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.bookView?.bookMarkup = attStr
        self.bookView?.backgroundColor = TKBookConfig.sharedInstance.backgroundColor;
        self.bookView?.aDelegate = self
        self.bookView?.location = 500
        
        
        let chapterTitle = "haa";
    
        self.bookView?.chapterTitle = NSAttributedString(string: chapterTitle, attributes: TKBookConfig.sharedInstance.titleAttDic)
        
        self.view.addSubview(self.bookView!)
        
        let tapFunc = #selector(tap(gesture:))
        
        let tapGesture = UITapGestureRecognizer(target: self, action:tapFunc)
        self.view.addGestureRecognizer(tapGesture)
        
        
        
        
        self.view.addSubview(bar)
        
        // Do any additional setup after loading the view.
    }
    
    
    func back() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tap(gesture:UIGestureRecognizer) -> Void {
       
        self.switchStatus()
    }
    
    func switchStatus() -> Void {
        self.isHiddenToolViews = !self.isHiddenToolViews
        UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), delay: 0.0, options: [.layoutSubviews,.curveLinear], animations: {
            self.navigationBarHidden(self.isHiddenToolViews)
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { (finish) in
            
        })
    }
    
    
    func navigationBarHidden(_ hidden:Bool) -> Void {
        
        let navBar = self.aNavigationBar;
        
        if !hidden{
            navBar?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        }else{
            navBar?.frame = CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: 64)
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
         self.bookView?.buildFrames()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return self.isHiddenToolViews ? true : false
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    
    // MARK: - TKBookViewDelegate

    
    func bookViewWillBeginLoading() {
        
        print("处理中")
    }
    
    func bookViewDidEndLoading() {
        print("处理结束")
    }
    
    func bookViewWillBeginDragging(_ bookView: TKBookView) {
        if self.isHiddenToolViews {
            return
        }
        self.switchStatus()
    }
    
    func bookViewDidEndDecelerating(_ bookView: TKBookView, _ location: Int) {
        print("当前阅读的位置： \(location)")
    }
}
