trigger TriggerOrder on Order (before update, after insert, after delete) {
    new TH_Order().run();
}